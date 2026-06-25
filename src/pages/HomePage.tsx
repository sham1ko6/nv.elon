import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../components/layout/Header';
import BottomNav from '../components/layout/BottomNav';
import SearchBar from '../components/ui/SearchBar';
import Chip from '../components/ui/Chip';
import Button from '../components/ui/Button';
import ListingCard from '../components/listing/ListingCard';
import { CATEGORY_CHIPS, LISTINGS } from '../data/mockData';
import styles from './HomePage.module.css';

const HomePage: React.FC = () => {
  const navigate = useNavigate();
  const [activeChip, setActiveChip] = useState(CATEGORY_CHIPS[0]);

  return (
    <div className={styles.page}>
      <Header />

      <div className={styles.section}>
        <SearchBar onFilterClick={() => navigate('/search')} onSubmit={() => navigate('/search')} />
      </div>

      <div className={`${styles.chipsRow} hideScrollbar`}>
        {CATEGORY_CHIPS.map((chip) => (
          <Chip key={chip} label={chip} active={chip === activeChip} onClick={() => setActiveChip(chip)} />
        ))}
      </div>

      <div className={styles.section}>
        <div className={styles.hero}>
          <h2 className={styles.heroTitle}>Yerdan bozorga, bir qadamda.</h2>
          <p className={styles.heroSubtitle}>
            Qishloq xo'jaligi, texnika va minglab e'lonlarni bir joydan toping.
          </p>
          <Button variant="outlined" className={styles.heroButton}>
            E'lon berish
          </Button>
        </div>
      </div>

      <div className={styles.section}>
        <div className={styles.sectionHeader}>
          <h3 className={styles.sectionTitle}>Tavsiya etiladi</h3>
          <button className={styles.sectionLink} type="button" onClick={() => navigate('/search')}>
            Barchasi →
          </button>
        </div>
        <div className={styles.grid}>
          {LISTINGS.map((listing) => (
            <ListingCard key={listing.id} listing={listing} />
          ))}
        </div>
      </div>

      <BottomNav />
    </div>
  );
};

export default HomePage;
