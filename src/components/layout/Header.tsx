import React from 'react';
import { ChevronDown, Bell } from 'lucide-react';
import styles from './Header.module.css';

interface HeaderProps {
  location?: string;
  avatarLetter?: string;
}

const Header: React.FC<HeaderProps> = ({ location = 'Toshkent sh.', avatarLetter = 'A' }) => {
  return (
    <header className={styles.header}>
      <div className={styles.left}>
        <span className={styles.logo}>nv.elon</span>
        <button className={styles.location} type="button">
          {location} <ChevronDown size={14} />
        </button>
      </div>
      <div className={styles.right}>
        <button className={styles.iconButton} type="button" aria-label="Bildirishnomalar">
          <Bell size={20} />
        </button>
        <div className={styles.avatar}>{avatarLetter}</div>
      </div>
    </header>
  );
};

export default Header;
