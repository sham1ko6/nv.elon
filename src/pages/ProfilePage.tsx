import React, { useState } from 'react';
import { Settings, Bell, Shield, Globe, HelpCircle, FileText, LogOut, ChevronRight } from 'lucide-react';
import BottomNav from '../components/layout/BottomNav';
import Button from '../components/ui/Button';
import Badge from '../components/ui/Badge';
import Chip from '../components/ui/Chip';
import ListingCard from '../components/listing/ListingCard';
import { LISTINGS } from '../data/mockData';
import styles from './ProfilePage.module.css';

const STATS = [
  { label: "E'lonlar", value: '4' },
  { label: "Ko'rishlar", value: '1240' },
  { label: 'Reytinglar', value: '4.8 ⭐' },
];

const LISTING_TABS = ['Aktiv (3)', 'Kutmoqda (1)', "Muddati o'tgan (0)"];

const MENU_ITEMS = [
  { icon: Bell, label: 'Bildirishnomalar' },
  { icon: Shield, label: 'Xavfsizlik' },
  { icon: Globe, label: "Til: O'zbek" },
  { icon: HelpCircle, label: 'Yordam' },
  { icon: FileText, label: 'Foydalanish shartlari' },
];

const ProfilePage: React.FC = () => {
  const [activeTab, setActiveTab] = useState(LISTING_TABS[0]);
  const myListings = LISTINGS.slice(0, 4);

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <h1 className={styles.title}>Profil</h1>
        <button className={styles.iconButton} type="button" aria-label="Sozlamalar">
          <Settings size={20} />
        </button>
      </div>

      <div className={styles.section}>
        <div className={styles.userCard}>
          <div className={styles.avatar}>S</div>
          <div className={styles.userName}>Shamshod</div>
          <div className={styles.userPhone}>+998 90 123 45 67</div>
          <Button variant="outlined" className={styles.editButton}>
            Profilni tahrirlash
          </Button>
          <div className={styles.statsRow}>
            {STATS.map((stat) => (
              <div key={stat.label} className={styles.statItem}>
                <span className={styles.statValue}>{stat.value}</span>
                <span className={styles.statLabel}>{stat.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className={styles.section}>
        <div className={styles.walletCard}>
          <span className={styles.walletLabel}>Hamyon balansi</span>
          <span className={styles.walletBalance}>45 000 so'm</span>
          <div className={styles.walletButtons}>
            <Button variant="primary" className={styles.walletFillBtn}>
              To'ldirish
            </Button>
            <Button variant="outlined" className={styles.walletOutlineBtn}>
              Chiqarish
            </Button>
          </div>
        </div>
      </div>

      <div className={styles.section}>
        <div className={styles.sectionHeader}>
          <h3 className={styles.sectionTitle}>Mening e'lonlarim</h3>
          <Badge>{myListings.length}</Badge>
        </div>

        <div className={`${styles.tabsRow} hideScrollbar`}>
          {LISTING_TABS.map((tab) => (
            <Chip key={tab} label={tab} active={tab === activeTab} onClick={() => setActiveTab(tab)} />
          ))}
        </div>

        <div className={styles.grid}>
          {myListings.map((listing) => (
            <div key={listing.id} className={styles.listingItem}>
              <ListingCard listing={listing} />
              <button className={styles.editLink} type="button">
                Tahrirlash
              </button>
            </div>
          ))}
        </div>
      </div>

      <div className={styles.section}>
        <div className={styles.menuList}>
          {MENU_ITEMS.map(({ icon: Icon, label }) => (
            <button key={label} className={styles.menuRow} type="button">
              <Icon size={19} className={styles.menuIcon} />
              <span className={styles.menuLabel}>{label}</span>
              <ChevronRight size={18} className={styles.menuChevron} />
            </button>
          ))}
          <button className={`${styles.menuRow} ${styles.logoutRow}`} type="button">
            <LogOut size={19} className={styles.logoutIcon} />
            <span className={styles.logoutLabel}>Chiqish</span>
          </button>
        </div>
      </div>

      <BottomNav />
    </div>
  );
};

export default ProfilePage;
