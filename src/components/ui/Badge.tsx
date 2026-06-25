import React from 'react';
import styles from './Badge.module.css';

interface BadgeProps {
  variant?: 'top' | 'category';
  children: React.ReactNode;
}

const Badge: React.FC<BadgeProps> = ({ variant = 'category', children }) => {
  return <span className={`${styles.badge} ${styles[variant]}`}>{children}</span>;
};

export default Badge;
