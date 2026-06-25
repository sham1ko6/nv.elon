import React from 'react';
import styles from './Chip.module.css';

interface ChipProps {
  label: string;
  active?: boolean;
  onClick?: () => void;
}

const Chip: React.FC<ChipProps> = ({ label, active = false, onClick }) => {
  return (
    <button
      className={`${styles.chip} ${active ? styles.active : ''}`}
      onClick={onClick}
      type="button"
    >
      {label}
    </button>
  );
};

export default Chip;
