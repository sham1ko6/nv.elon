import React, { useState, useEffect, useRef } from 'react';
import { c, serif, sans } from '../theme';
import { Close, Plus, ChevronDown, Star } from '../icons';
import { useNav, StatusBar } from '../shell';
import { api, API_ROOT } from '../api';

export const PostAdScreen = () => {
  const { back, navigate, params } = useNav();

  // edit mode — params.id is set when coming from MyAds "Tahrirlash"
  const editId: string | null = params.id ?? null;
  const isEdit = !!editId;

  // form fields
  const [title, setTitle]               = useState('');
  const [description, setDescription]   = useState('');
  const [priceStr, setPriceStr]         = useState('');
  const [currency, setCurrency]         = useState<'USD' | 'UZS'>('USD');
  const [categoryId, setCategoryId]     = useState<number | null>(null);
  const [categoryName, setCategoryName] = useState('');
  const [location, setLocation]         = useState('');
  const [phone, setPhone]               = useState('');
  const [files, setFiles]               = useState<File[]>([]);
  const [previews, setPreviews]         = useState<string[]>([]);
  const [promote, setPromote]           = useState(false);

  // existing images (edit mode only)
  const [existingImages, setExistingImages] = useState<{ id: number; url: string }[]>([]);

  // remote data
  const [categories, setCategories] = useState<any[]>([]);

  // ui state
  const [loadingInitial, setLoadingInitial] = useState(isEdit);
  const [showCatSheet, setShowCatSheet]     = useState(false);
  const [submitting, setSubmitting]         = useState(false);
  const [error, setError]                   = useState<string | null>(null);

  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    // always load categories for the picker
    api.getCategories()
      .then((res: any) => setCategories(res.data))
      .catch(() => {});

    if (isEdit) {
      // fetch existing listing to pre-fill the form
      api.getListing(editId!)
        .then((res: any) => {
          const l = res.listing ?? {};
          setTitle(l.title ?? '');
          setDescription(l.description ?? '');
          setPriceStr(String(l.price ?? ''));
          setCurrency(l.currency === 'USD' ? 'USD' : 'UZS');
          setCategoryId(l.category_id ?? null);
          setLocation(l.location ?? '');
          setPhone(l.contact_phone ?? '');
          setExistingImages(res.images ?? []);
        })
        .catch(() => {})
        .finally(() => setLoadingInitial(false));
    } else {
      // new listing — pre-fill contact phone from user profile
      api.me()
        .then((res: any) => setPhone(res.user.phone))
        .catch(() => {});
    }

    return () => { previews.forEach(URL.revokeObjectURL); };
  }, []);

  // resolve category name once both categories and categoryId are known (edit mode)
  useEffect(() => {
    if (categoryId && categories.length > 0 && !categoryName) {
      const cat = categories.find((c: any) => c.id === categoryId);
      if (cat) setCategoryName(cat.name_uz);
    }
  }, [categories, categoryId]);

  const handleFiles = (e: React.ChangeEvent<HTMLInputElement>) => {
    previews.forEach(URL.revokeObjectURL);
    const remaining = 8 - existingImages.length;
    const picked = Array.from(e.target.files ?? []).slice(0, remaining);
    setFiles(picked);
    setPreviews(picked.map(f => URL.createObjectURL(f)));
  };

  const handleSubmit = async () => {
    setError(null);
    if (!title.trim())       { setError("Sarlavha talab qilinadi"); return; }
    if (!description.trim()) { setError("Tavsif talab qilinadi"); return; }
    const priceNum = Number(priceStr.replace(/\s/g, '').replace(',', '.'));
    if (!priceNum || priceNum <= 0) { setError("To'g'ri narx kiriting"); return; }
    if (!categoryId)         { setError("Kategoriya tanlang"); return; }
    if (!location.trim())    { setError("Manzil talab qilinadi"); return; }
    if (!phone.trim())       { setError("Telefon raqami talab qilinadi"); return; }

    const payload = {
      title:         title.trim(),
      description:   description.trim(),
      price:         priceNum,
      currency,
      category_id:   categoryId,
      location:      location.trim(),
      contact_phone: phone.trim(),
    };

    setSubmitting(true);
    try {
      if (isEdit) {
        await api.updateListing(editId!, payload);
        if (files.length > 0) {
          await api.uploadImages(editId!, files).catch(() => {});
        }
        navigate('myAds');
      } else {
        const res = await api.createListing(payload);
        const listingId = res.listing?.id;
        if (listingId && files.length > 0) {
          await api.uploadImages(listingId, files).catch(() => {});
        }
        if (res.listing?.status === 'pending_payment') {
          navigate('payment', { order_id: res.order_id });
        } else {
          navigate('myAds');
        }
      }
    } catch (e: any) {
      setError(e.message);
    } finally {
      setSubmitting(false);
    }
  };

  // ── loading state (edit mode only) ───────────────────────────────────────
  if (loadingInitial) {
    return (
      <>
        <StatusBar />
        <div style={{ flex: 1, display: 'flex', alignItems: 'center',
          justifyContent: 'center', fontSize: 12, color: c.muted, fontWeight: 600 }}>
          Yuklanmoqda…
        </div>
      </>
    );
  }

  return (
    <>
      <StatusBar />

      {/* header */}
      <div style={{ flexShrink: 0, padding: '4px 16px 12px', display: 'flex',
        alignItems: 'center', justifyContent: 'space-between',
        borderBottom: `1px solid ${c.line}` }}>
        <button onClick={back} aria-label="Yopish" style={{ width: 32, height: 32,
          border: 'none', borderRadius: '50%', background: c.card,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: c.ink, cursor: 'pointer' }}>
          <Close size={16} />
        </button>
        <span style={{ fontFamily: serif, fontSize: 16, fontWeight: 700, color: c.ink }}>
          {isEdit ? "E'lonni tahrirlash" : "Yangi e'lon"}
        </span>
        <span style={{ fontSize: 11, fontWeight: 700, color: c.muted }}>
          {isEdit ? '' : '1/2'}
        </span>
      </div>

      {/* hidden file input */}
      <input ref={fileInputRef} type="file" multiple accept="image/*"
        onChange={handleFiles} style={{ display: 'none' }} />

      <div style={{ flex: 1, overflowY: 'auto', padding: '14px 16px',
        display: 'flex', flexDirection: 'column', gap: 13 }}>

        {/* images */}
        <div>
          <FieldLabel>
            Rasmlar{' '}
            <span style={{ color: c.muted, fontWeight: 500 }}>
              ({existingImages.length + files.length}/8)
            </span>
          </FieldLabel>
          <div style={{ display: 'flex', gap: 9, flexWrap: 'wrap' }}>
            {/* add button — hidden when at limit */}
            {existingImages.length + files.length < 8 && (
              <button onClick={() => fileInputRef.current?.click()} style={{ width: 74, height: 74,
                borderRadius: 13, border: '2px dashed #cdb89a', background: c.card,
                display: 'flex', flexDirection: 'column', alignItems: 'center',
                justifyContent: 'center', gap: 3, color: c.accent, cursor: 'pointer',
                flexShrink: 0 }}>
                <Plus size={20} />
                <span style={{ fontSize: 8.5, fontWeight: 700 }}>Qo'shish</span>
              </button>
            )}

            {/* existing images from the server (edit mode) */}
            {existingImages.map((img) => (
              <div key={img.id} style={{ width: 74, height: 74, borderRadius: 13,
                overflow: 'hidden', flexShrink: 0, position: 'relative' }}>
                <img
                  src={img.url.startsWith('/') ? `${API_ROOT}${img.url}` : img.url}
                  alt="" style={{ width: '100%', height: '100%', objectFit: 'cover',
                    display: 'block' }} />
              </div>
            ))}

            {/* new local file previews */}
            {previews.length > 0
              ? previews.map((src, i) => (
                  <div key={i} style={{ width: 74, height: 74, borderRadius: 13,
                    overflow: 'hidden', flexShrink: 0 }}>
                    <img src={src} alt="" style={{ width: '100%', height: '100%',
                      objectFit: 'cover', display: 'block' }} />
                  </div>
                ))
              : existingImages.length === 0 && [0, 1].map(i => (
                  <div key={i} style={{ width: 74, height: 74, borderRadius: 13,
                    background: 'repeating-linear-gradient(135deg,#e7d8c0,#e7d8c0 8px,#efe3cf 8px,#efe3cf 16px)' }} />
                ))
            }
          </div>
        </div>

        {/* title */}
        <div>
          <FieldLabel>Sarlavha</FieldLabel>
          <input value={title} onChange={e => setTitle(e.target.value)}
            placeholder="Masalan: John Deere traktori sotiladi"
            style={inputStyle} />
        </div>

        {/* description */}
        <div>
          <FieldLabel>Tavsif</FieldLabel>
          <textarea value={description} onChange={e => setDescription(e.target.value)}
            placeholder="Mahsulot holati, xususiyatlari va boshqa ma'lumotlar…"
            rows={3}
            style={{ ...inputStyle, height: 'auto', padding: '10px 12px',
              resize: 'none', lineHeight: 1.5 }} />
        </div>

        {/* category */}
        <div>
          <FieldLabel>Kategoriya</FieldLabel>
          <button onClick={() => setShowCatSheet(true)} style={{ ...inputStyle,
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            cursor: 'pointer', fontWeight: categoryId ? 600 : 400,
            color: categoryId ? c.ink : '#a8957d' }}>
            {categoryName || 'Kategoriyani tanlang'}
            <ChevronDown size={13} color={c.muted} />
          </button>
        </div>

        {/* price + currency */}
        <div style={{ display: 'flex', gap: 10 }}>
          <div style={{ flex: 1.4 }}>
            <FieldLabel>Narx</FieldLabel>
            <input value={priceStr} onChange={e => setPriceStr(e.target.value)}
              placeholder="0" inputMode="numeric"
              style={{ ...inputStyle, fontWeight: 700 }} />
          </div>
          <div style={{ flex: 1 }}>
            <FieldLabel>Valyuta</FieldLabel>
            <div style={{ display: 'flex', background: c.card, border: `1px solid ${c.line}`,
              borderRadius: 11, padding: 3, height: 42 }}>
              {(['USD', 'UZS'] as const).map(cur => {
                const on = cur === currency;
                return (
                  <button key={cur} onClick={() => setCurrency(cur)} style={{ flex: 1,
                    fontSize: 11.5, fontWeight: 700,
                    color: on ? '#fff' : c.muted,
                    background: on ? c.accent : 'transparent',
                    border: 'none', borderRadius: 8, cursor: 'pointer' }}>
                    {cur}
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* location */}
        <div>
          <FieldLabel>Joylashuv</FieldLabel>
          <input value={location} onChange={e => setLocation(e.target.value)}
            placeholder="Masalan: Toshkent sh., Yunusobod"
            style={inputStyle} />
        </div>

        {/* contact phone */}
        <div>
          <FieldLabel>Aloqa raqami</FieldLabel>
          <input value={phone} onChange={e => setPhone(e.target.value)}
            placeholder="+998901234567" inputMode="tel"
            style={inputStyle} />
        </div>

        {/* TOP promotion toggle */}
        <button onClick={() => setPromote(!promote)} style={{ textAlign: 'left',
          background: 'linear-gradient(135deg,#3a2a1c,#5a3a22)', borderRadius: 16,
          padding: 14, position: 'relative', overflow: 'hidden',
          border: promote ? `2px solid ${c.gold}` : '2px solid transparent',
          cursor: 'pointer' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
            <Star size={16} fill={c.gold} color={c.gold} />
            <span style={{ fontFamily: serif, fontSize: 14, fontWeight: 700, color: '#fff' }}>
              E'lonni TOP'ga ko'taring
            </span>
          </div>
          <div style={{ fontSize: 10.5, color: 'rgba(255,255,255,.7)', marginTop: 5, lineHeight: 1.45 }}>
            5 barobar ko'proq ko'rish · 7 kun yuqorida turadi.
          </div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            marginTop: 11 }}>
            <span style={{ fontFamily: serif, fontSize: 15, fontWeight: 700, color: c.gold }}>
              19 000 so'm
            </span>
            <span style={{ fontSize: 11, fontWeight: 700, color: '#3a2a1c', background: c.gold,
              borderRadius: 8, padding: '6px 13px' }}>
              {promote ? "Qo'shildi ✓" : "Ko'tarish"}
            </span>
          </div>
        </button>

        {/* error */}
        {error && (
          <div style={{ fontSize: 12, color: '#c0392b', fontWeight: 600,
            textAlign: 'center', lineHeight: 1.45, padding: '4px 0' }}>
            {error}
          </div>
        )}
      </div>

      {/* submit */}
      <div style={{ flexShrink: 0, height: 72, background: c.card,
        borderTop: `1px solid ${c.line}`, display: 'flex',
        alignItems: 'center', padding: '0 16px' }}>
        <button onClick={handleSubmit} disabled={submitting}
          style={{ flex: 1, height: 48, border: 'none', borderRadius: 14,
            background: submitting ? '#d4a88a' : c.accent, color: '#fff',
            fontSize: 13.5, fontWeight: 700, cursor: submitting ? 'default' : 'pointer',
            boxShadow: submitting ? 'none' : '0 8px 16px rgba(194,97,59,.32)' }}>
          {submitting ? 'Yuklanmoqda…' : isEdit ? 'Saqlash' : 'Davom etish'}
        </button>
      </div>

      {/* category sheet */}
      {showCatSheet && (
        <div onClick={() => setShowCatSheet(false)} style={{ position: 'absolute', inset: 0,
          background: 'rgba(21,17,13,.32)', zIndex: 25, display: 'flex', alignItems: 'flex-end' }}>
          <div onClick={e => e.stopPropagation()} style={{ width: '100%', background: c.bg,
            borderRadius: '24px 24px 0 0', boxShadow: '0 -12px 30px rgba(40,24,10,.18)',
            padding: '10px 0 20px', maxHeight: '70%', display: 'flex', flexDirection: 'column' }}>
            <div style={{ width: 38, height: 4, borderRadius: 3, background: '#d8cab3',
              margin: '2px auto 12px' }} />
            <div style={{ fontFamily: serif, fontSize: 17, fontWeight: 700, color: c.ink,
              padding: '0 18px 12px', flexShrink: 0 }}>
              Kategoriya
            </div>
            <div style={{ overflowY: 'auto', flex: 1 }}>
              {categories.map((cat: any) => (
                <button key={cat.id} onClick={() => {
                  setCategoryId(cat.id);
                  setCategoryName(cat.name_uz);
                  setShowCatSheet(false);
                }} style={{ width: '100%', textAlign: 'left', display: 'flex',
                  alignItems: 'center', justifyContent: 'space-between',
                  padding: '13px 18px', background: 'none', border: 'none',
                  borderBottom: `1px solid ${c.line}`, cursor: 'pointer' }}>
                  <span style={{ fontSize: 13, fontWeight: 600, color: c.ink }}>
                    {cat.name_uz}
                  </span>
                  {cat.id === categoryId && (
                    <span style={{ width: 8, height: 8, borderRadius: '50%',
                      background: c.accent, flexShrink: 0 }} />
                  )}
                </button>
              ))}
              {categories.length === 0 && (
                <div style={{ textAlign: 'center', padding: 24, fontSize: 12,
                  color: c.muted }}>
                  Yuklanmoqda…
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
};

const FieldLabel = ({ children }: { children: React.ReactNode }) => (
  <div style={{ fontSize: 11, fontWeight: 700, color: c.ink, marginBottom: 6 }}>
    {children}
  </div>
);

const inputStyle: React.CSSProperties = {
  width: '100%', height: 42, borderRadius: 11, background: c.card,
  border: `1px solid ${c.line}`, padding: '0 12px', fontSize: 12.5,
  color: c.ink, outline: 'none', fontFamily: sans,
};
