import React, { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, Search, SlidersHorizontal, ChevronDown } from 'lucide-react';
import ListingRow from '../components/listing/ListingRow';
import FilterBottomSheet from '../components/ui/FilterBottomSheet';
import { LISTINGS } from '../data/mockData';
import styles from './SearchPage.module.css';

const SearchPage: React.FC = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [query, setQuery] = useState(searchParams.get('q') ?? '');
  const [filterOpen, setFilterOpen] = useState(false);

  const results = LISTINGS;

  return (
    <div className={styles.page}>
      <div className={styles.topBar}>
        <button className={styles.iconButton} type="button" onClick={() => navigate(-1)}>
          <ArrowLeft size={20} />
        </button>
        <div className={styles.inputWrap}>
          <Search size={17} className={styles.searchIcon} />
          <input
            className={styles.input}
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Qidiruv: traktor, iPhone..."
          />
        </div>
        <button className={styles.filterButton} type="button" onClick={() => setFilterOpen(true)}>
          <SlidersHorizontal size={17} color="#fff" />
        </button>
      </div>

      <div className={styles.resultBar}>
        <span className={styles.resultCount}>{results.length} ta natija</span>
        <button className={styles.sortButton} type="button">
          Eng yangi <ChevronDown size={14} />
        </button>
      </div>

      <div className={styles.list}>
        {results.map((listing) => (
          <ListingRow key={listing.id} listing={listing} />
        ))}
      </div>

      <FilterBottomSheet
        open={filterOpen}
        onClose={() => setFilterOpen(false)}
        resultCount={results.length}
      />
    </div>
  );
};

export default SearchPage;
