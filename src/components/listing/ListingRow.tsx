import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye, Clock } from 'lucide-react';
import type { Listing } from '../../data/mockData';
import ImagePlaceholder from '../ui/ImagePlaceholder';
import Badge from '../ui/Badge';
import styles from './ListingRow.module.css';

interface ListingRowProps {
  listing: Listing;
}

const formatPrice = (price: number, currency: string) =>
  `${currency}${price.toLocaleString('en-US').replace(/,/g, ' ')}`;

const ListingRow: React.FC<ListingRowProps> = ({ listing }) => {
  const navigate = useNavigate();

  return (
    <div className={styles.row} onClick={() => navigate(`/listing/${listing.id}`)}>
      <div className={styles.imageWrap}>
        <ImagePlaceholder height={88} radius="var(--radius-sm)" className={styles.image} />
        {listing.isTop && (
          <span className={styles.topBadge}>
            <Badge variant="top">TOP</Badge>
          </span>
        )}
      </div>
      <div className={styles.body}>
        <div className={styles.price}>{formatPrice(listing.price, listing.currency)}</div>
        <div className={styles.title}>{listing.title}</div>
        <div className={styles.location}>{listing.location}</div>
        <div className={styles.meta}>
          <span className={styles.metaItem}>
            <Eye size={12} /> {listing.views}
          </span>
          <span className={styles.metaItem}>
            <Clock size={12} /> {listing.date}
          </span>
        </div>
      </div>
    </div>
  );
};

export default ListingRow;
