import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Heart } from 'lucide-react';
import type { Listing } from '../../data/mockData';
import ImagePlaceholder from '../ui/ImagePlaceholder';
import Badge from '../ui/Badge';
import styles from './ListingCard.module.css';

interface ListingCardProps {
  listing: Listing;
  saved?: boolean;
  onToggleSave?: (id: string) => void;
}

const formatPrice = (price: number, currency: string) =>
  `${currency}${price.toLocaleString('en-US').replace(/,/g, ' ')}`;

const ListingCard: React.FC<ListingCardProps> = ({ listing, saved, onToggleSave }) => {
  const navigate = useNavigate();

  return (
    <div className={styles.card} onClick={() => navigate(`/listing/${listing.id}`)}>
      <div className={styles.imageWrap}>
        <ImagePlaceholder height={120} radius="var(--radius-md) var(--radius-md) 0 0" />
        {listing.isTop && (
          <span className={styles.topBadge}>
            <Badge variant="top">TOP</Badge>
          </span>
        )}
        {onToggleSave && (
          <button
            className={styles.heartButton}
            type="button"
            aria-label="Saqlash"
            onClick={(e) => {
              e.stopPropagation();
              onToggleSave(listing.id);
            }}
          >
            <Heart size={15} fill={saved ? '#E5484D' : 'none'} color={saved ? '#E5484D' : '#fff'} />
          </button>
        )}
      </div>
      <div className={styles.body}>
        <div className={styles.price}>{formatPrice(listing.price, listing.currency)}</div>
        <div className={styles.title}>{listing.title}</div>
        <div className={styles.location}>{listing.location}</div>
      </div>
    </div>
  );
};

export default ListingCard;
