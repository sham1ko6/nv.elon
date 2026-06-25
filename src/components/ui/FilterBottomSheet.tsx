import React, { useState } from 'react';
import BottomSheet from './BottomSheet';
import Chip from './Chip';
import Button from './Button';
import styles from './FilterBottomSheet.module.css';

interface FilterBottomSheetProps {
  open: boolean;
  onClose: () => void;
  resultCount: number;
}

const CONDITION_OPTIONS = ['Hammasi', 'Yangi', 'Ishlatilgan'];
const SELLER_OPTIONS = ['Shaxsiy', 'Kompaniya'];

const FilterBottomSheet: React.FC<FilterBottomSheetProps> = ({ open, onClose, resultCount }) => {
  const [minPrice, setMinPrice] = useState('');
  const [maxPrice, setMaxPrice] = useState('5000');
  const [sliderValue, setSliderValue] = useState(60);
  const [condition, setCondition] = useState(CONDITION_OPTIONS[0]);
  const [sellerType, setSellerType] = useState<string | null>(null);

  const handleClear = () => {
    setMinPrice('');
    setMaxPrice('5000');
    setSliderValue(60);
    setCondition(CONDITION_OPTIONS[0]);
    setSellerType(null);
  };

  return (
    <BottomSheet open={open} onClose={onClose}>
      <div className={styles.header}>
        <h3 className={styles.title}>Filtrlar</h3>
        <button className={styles.clearButton} type="button" onClick={handleClear}>
          Tozalash
        </button>
      </div>

      <div className={styles.block}>
        <span className={styles.label}>NARX ORALIG'I, $</span>
        <div className={styles.priceInputs}>
          <input
            className={styles.priceInput}
            type="number"
            placeholder="Dan"
            value={minPrice}
            onChange={(e) => setMinPrice(e.target.value)}
          />
          <span className={styles.priceDash}>—</span>
          <input
            className={styles.priceInput}
            type="number"
            placeholder="Gacha"
            value={maxPrice}
            onChange={(e) => setMaxPrice(e.target.value)}
          />
        </div>
        <input
          className={styles.slider}
          type="range"
          min={0}
          max={100}
          value={sliderValue}
          onChange={(e) => setSliderValue(Number(e.target.value))}
        />
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
            <Chip
              key={opt}
              label={opt}
              active={sellerType === opt}
              onClick={() => setSellerType(sellerType === opt ? null : opt)}
            />
          ))}
        </div>
      </div>

      <Button variant="primary" fullWidth className={styles.cta} onClick={onClose}>
        {resultCount} ta natijani ko'rsatish
      </Button>
    </BottomSheet>
  );
};

export default FilterBottomSheet;
