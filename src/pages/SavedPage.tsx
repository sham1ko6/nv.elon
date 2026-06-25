import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { SlidersHorizontal, Heart } from 'lucide-react';
import BottomNav from '../components/layout/BottomNav';
import Button from '../components/ui/Button';
import ListingCard from '../components/listing/ListingCard';
import { LISTINGS } from '../data/mockData';
import styles from './SavedPage.module.css';

const SavedPage: React.FC = () => {
  const navigate = useNavigate();
  const [savedIds, setSavedIds] = useState<string[]>(LISTINGS.map((l) => l.id));

  const toggleSave = (id: string) => {
    setSavedIds((prev) => (prev.includes(id) ? prev.filter((i) => i !== id) : [...prev, id]));
  };

  const savedListings = LISTINGS.filter((l) => savedIds.includes(l.id));

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>Saqlangan</h1>
          {savedListings.length > 0 && (
            <p className={styles.subtitle}>{savedListings.length} ta saqlangan</p>
          )}
        </div>
        <button className={styles.iconButton} type="button" aria-label="Filtr">
          <SlidersHorizontal size={20} />
        </button>
      </div>

      {savedListings.length === 0 ? (
        <div className={styles.empty}>
          <Heart size={64} className={styles.emptyIcon} />
          <p className={styles.emptyText}>Hali saqlangan e'lonlar yo'q</p>
          <p className={styles.emptySubtext}>E'lonlarni yurakcha bosib saqlang</p>
          <Button variant="primary" onClick={() => navigate('/')}>
            E'lonlarni ko'rish
          </Button>
        </div>
      ) : (
        <div className={styles.grid}>
          {savedListings.map((listing) => (
            <ListingCard
              key={listing.id}
              listing={listing}
              saved={savedIds.includes(listing.id)}
              onToggleSave={toggleSave}
            />
          ))}
        </div>
      )}

      <BottomNav />
    </div>
  );
};

export default SavedPage;
