import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, ChevronRight } from 'lucide-react';
import BottomNav from '../components/layout/BottomNav';
import { CATEGORIES } from '../data/mockData';
import styles from './CategoriesPage.module.css';

const CategoriesPage: React.FC = () => {
  const navigate = useNavigate();
  const [query, setQuery] = useState('');

  const filtered = CATEGORIES.filter((c) =>
    c.name.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <h1 className={styles.heading}>Kategoriyalar</h1>
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
      </div>

      <div className={styles.list}>
        {filtered.map((category) => (
          <button
            key={category.id}
            className={styles.row}
            type="button"
            onClick={() => navigate('/search')}
          >
            <span className={styles.icon}>{category.icon}</span>
            <span className={styles.name}>{category.name}</span>
            <span className={styles.count}>{category.count} e'lon</span>
            <ChevronRight size={18} className={styles.chevron} />
          </button>
        ))}
      </div>

      <BottomNav />
    </div>
  );
};

export default CategoriesPage;
