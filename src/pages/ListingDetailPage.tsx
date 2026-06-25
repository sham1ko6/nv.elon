import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, Share2, Heart, Eye, Clock } from 'lucide-react';
import ImagePlaceholder from '../components/ui/ImagePlaceholder';
import Chip from '../components/ui/Chip';
import Button from '../components/ui/Button';
import SellerCard from '../components/listing/SellerCard';
import { LISTINGS } from '../data/mockData';
import styles from './ListingDetailPage.module.css';

const formatPrice = (price: number, currency: string) =>
  `${currency}${price.toLocaleString('en-US').replace(/,/g, ' ')}`;

const ListingDetailPage: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [imageIndex, setImageIndex] = useState(1);
  const [liked, setLiked] = useState(false);

  const listing = LISTINGS.find((l) => l.id === id) ?? LISTINGS[0];

  return (
    <div className={styles.page}>
      <div className={styles.imageSection}>
        <ImagePlaceholder
          height={280}
          radius="0 0 var(--radius-xl) var(--radius-xl)"
          onClick={() =>
            setImageIndex((i) => (i % listing.imageCount) + 1)
          }
        />
        <div className={styles.headerOverlay}>
          <button className={styles.iconButton} type="button" onClick={() => navigate(-1)}>
            <ArrowLeft size={20} />
          </button>
          <div className={styles.headerRight}>
            <button className={styles.iconButton} type="button">
              <Share2 size={19} />
            </button>
            <button
              className={styles.iconButton}
              type="button"
              onClick={() => setLiked((v) => !v)}
            >
              <Heart size={19} fill={liked ? 'var(--c-accent)' : 'none'} color={liked ? 'var(--c-accent)' : 'currentColor'} />
            </button>
          </div>
        </div>
        <span className={styles.imageCounter}>
          {imageIndex} / {listing.imageCount}
        </span>
      </div>

      <div className={styles.content}>
        <div className={styles.metaRow}>
          <span className={styles.category}>
            {listing.categoryLabel.toUpperCase()} · {listing.subcategoryLabel.toUpperCase()}
          </span>
          <span className={styles.date}>{listing.date}</span>
        </div>

        <div className={styles.price}>{formatPrice(listing.price, listing.currency)}</div>
        <h1 className={styles.title}>{listing.title}</h1>

        <div className={`${styles.chipsRow} hideScrollbar`}>
          {listing.propertyChips.map((chip) => (
            <Chip key={chip} label={chip} />
          ))}
        </div>

        <div className={styles.statsRow}>
          <span className={styles.statItem}>
            <Eye size={13} /> {listing.views} ko'rish
          </span>
          <span className={styles.statItem}>
            <Clock size={13} /> {listing.date}
          </span>
        </div>

        <div className={styles.descriptionSection}>
          <h3 className={styles.sectionHeading}>Tavsif</h3>
          <p className={styles.descriptionText}>{listing.description}</p>
        </div>

        <SellerCard seller={listing.seller} />
      </div>

      <div className={styles.bottomBar}>
        <Button variant="outlined" fullWidth>
          Xabar
        </Button>
        <Button variant="primary" fullWidth>
          Qo'ng'iroq
        </Button>
      </div>
    </div>
  );
};

export default ListingDetailPage;
