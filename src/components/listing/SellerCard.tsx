import React from 'react';
import { CheckCircle2, Star, ChevronRight } from 'lucide-react';
import type { Seller } from '../../data/mockData';
import styles from './SellerCard.module.css';

interface SellerCardProps {
  seller: Seller;
}

const SellerCard: React.FC<SellerCardProps> = ({ seller }) => {
  return (
    <button className={styles.card} type="button">
      <div className={styles.avatar}>{seller.initials}</div>
      <div className={styles.info}>
        <div className={styles.nameRow}>
          <span className={styles.name}>{seller.name}</span>
          {seller.verified && <CheckCircle2 size={15} className={styles.verified} />}
        </div>
        <div className={styles.rating}>
          <Star size={13} className={styles.star} />
          {seller.rating.toFixed(1)} ({seller.reviewCount})
        </div>
      </div>
      <ChevronRight size={20} className={styles.chevron} />
    </button>
  );
};

export default SellerCard;
