import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { Home, Grid3x3, Plus, Bookmark, User } from 'lucide-react';
import styles from './BottomNav.module.css';

const BottomNav: React.FC = () => {
  const navigate = useNavigate();

  return (
    <nav className={styles.nav}>
      <NavLink
        to="/"
        end
        className={({ isActive }) => `${styles.tab} ${isActive ? styles.active : ''}`}
      >
        <Home size={22} />
        <span>Asosiy</span>
      </NavLink>
      <NavLink
        to="/categories"
        className={({ isActive }) => `${styles.tab} ${isActive ? styles.active : ''}`}
      >
        <Grid3x3 size={22} />
        <span>Rukn</span>
      </NavLink>
      <button
        className={styles.fabWrap}
        type="button"
        aria-label="E'lon qo'shish"
        onClick={() => navigate('/new-listing')}
      >
        <span className={styles.fab}>
          <Plus size={26} color="#fff" />
        </span>
      </button>
      <NavLink
        to="/saved"
        className={({ isActive }) => `${styles.tab} ${isActive ? styles.active : ''}`}
      >
        <Bookmark size={22} />
        <span>Saqlangan</span>
      </NavLink>
      <NavLink
        to="/profile"
        className={({ isActive }) => `${styles.tab} ${isActive ? styles.active : ''}`}
      >
        <User size={22} />
        <span>Profil</span>
      </NavLink>
    </nav>
  );
};

export default BottomNav;
