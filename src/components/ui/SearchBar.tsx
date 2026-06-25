import React from 'react';
import { Search, SlidersHorizontal } from 'lucide-react';
import styles from './SearchBar.module.css';

interface SearchBarProps {
  value?: string;
  onChange?: (value: string) => void;
  onFilterClick?: () => void;
  onSubmit?: (value: string) => void;
  autoFocus?: boolean;
}

const SearchBar: React.FC<SearchBarProps> = ({
  value,
  onChange,
  onFilterClick,
  onSubmit,
  autoFocus,
}) => {
  return (
    <form
      className={styles.wrapper}
      onSubmit={(e) => {
        e.preventDefault();
        onSubmit?.(value ?? '');
      }}
    >
      <div className={styles.inputWrap}>
        <Search size={18} className={styles.searchIcon} />
        <input
          className={styles.input}
          type="text"
          placeholder="Qidiruv: traktor, iPhone..."
          value={value}
          autoFocus={autoFocus}
          onChange={(e) => onChange?.(e.target.value)}
        />
      </div>
      {onFilterClick && (
        <button type="button" className={styles.filterButton} onClick={onFilterClick}>
          <SlidersHorizontal size={18} color="#fff" />
        </button>
      )}
    </form>
  );
};

export default SearchBar;
