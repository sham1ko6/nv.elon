import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Plus, X } from 'lucide-react';
import ImagePlaceholder from '../components/ui/ImagePlaceholder';
import Chip from '../components/ui/Chip';
import Button from '../components/ui/Button';
import { CATEGORIES } from '../data/mockData';
import styles from './NewListingPage.module.css';

const CONDITION_OPTIONS = ['Yangi', 'Ishlatilgan'];
const SELLER_OPTIONS = ['Shaxsiy', 'Kompaniya'];
const CURRENCY_OPTIONS = ['$', "so'm"];
const MAX_PHOTOS = 8;

const NewListingPage: React.FC = () => {
  const navigate = useNavigate();
  const [photos, setPhotos] = useState<number[]>([]);
  const [category, setCategory] = useState(CATEGORIES[0].id);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  const [currency, setCurrency] = useState(CURRENCY_OPTIONS[0]);
  const [condition, setCondition] = useState(CONDITION_OPTIONS[0]);
  const [sellerType, setSellerType] = useState(SELLER_OPTIONS[0]);
  const [location, setLocation] = useState('');

  const addPhoto = () => {
    if (photos.length >= MAX_PHOTOS) return;
    setPhotos((prev) => [...prev, Date.now()]);
  };

  const removePhoto = (key: number) => {
    setPhotos((prev) => prev.filter((p) => p !== key));
  };

  const handleSubmit = () => {
    navigate('/');
  };

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <button className={styles.backButton} type="button" onClick={() => navigate(-1)}>
          <ArrowLeft size={20} />
        </button>
        <h1 className={styles.title}>Yangi e'lon</h1>
      </div>

      <div className={styles.content}>
        <div className={styles.block}>
          <span className={styles.label}>RASMLAR</span>
          <div className={`${styles.photosRow} hideScrollbar`}>
            <button className={styles.addPhoto} type="button" onClick={addPhoto}>
              <Plus size={22} />
              <span>Rasm</span>
            </button>
            {photos.map((key) => (
              <div key={key} className={styles.photoTile}>
                <ImagePlaceholder height={88} radius="var(--radius-md)" />
                <button
                  className={styles.removePhoto}
                  type="button"
                  aria-label="O'chirish"
                  onClick={() => removePhoto(key)}
                >
                  <X size={13} color="#fff" />
                </button>
              </div>
            ))}
          </div>
        </div>

        <div className={styles.block}>
          <span className={styles.label}>KATEGORIYA</span>
          <div className={`${styles.chipsRow} hideScrollbar`}>
            {CATEGORIES.map((c) => (
              <Chip
                key={c.id}
                label={c.name}
                active={category === c.id}
                onClick={() => setCategory(c.id)}
              />
            ))}
          </div>
        </div>

        <div className={styles.block}>
          <span className={styles.label}>SARLAVHA</span>
          <input
            className={styles.textInput}
            type="text"
            placeholder="Masalan: iPhone 14 Pro, 256GB"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
        </div>

        <div className={styles.block}>
          <span className={styles.label}>TAVSIF</span>
          <textarea
            className={styles.textarea}
            placeholder="Mahsulot haqida batafsil yozing..."
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={4}
          />
        </div>

        <div className={styles.block}>
          <span className={styles.label}>NARX</span>
          <div className={styles.priceRow}>
            <input
              className={styles.priceInput}
              type="number"
              placeholder="0"
              value={price}
              onChange={(e) => setPrice(e.target.value)}
            />
            <div className={styles.currencyChips}>
              {CURRENCY_OPTIONS.map((opt) => (
                <Chip key={opt} label={opt} active={currency === opt} onClick={() => setCurrency(opt)} />
              ))}
            </div>
          </div>
        </div>

        <div className={styles.block}>
          <span className={styles.label}>HOLATI</span>
          <div className={styles.chipsRow}>
            {CONDITION_OPTIONS.map((opt) => (
              <Chip key={opt} label={opt} active={condition === opt} onClick={() => setCondition(opt)} />
            ))}
          </div>
        </div>

        <div className={styles.block}>
          <span className={styles.label}>SOTUVCHI TURI</span>
          <div className={styles.chipsRow}>
            {SELLER_OPTIONS.map((opt) => (
              <Chip key={opt} label={opt} active={sellerType === opt} onClick={() => setSellerType(opt)} />
            ))}
          </div>
        </div>

        <div className={styles.block}>
          <span className={styles.label}>JOYLASHUV</span>
          <input
            className={styles.textInput}
            type="text"
            placeholder="Masalan: Toshkent sh., Chilonzor"
            value={location}
            onChange={(e) => setLocation(e.target.value)}
          />
        </div>
      </div>

      <div className={styles.bottomBar}>
        <Button variant="primary" fullWidth onClick={handleSubmit}>
          E'lonni joylash
        </Button>
      </div>
    </div>
  );
};

export default NewListingPage;
