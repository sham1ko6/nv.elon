import React from 'react';
import { useNavigate } from 'react-router-dom';
import { PenSquare, MessageCircle } from 'lucide-react';
import BottomNav from '../components/layout/BottomNav';
import Button from '../components/ui/Button';
import { CONVERSATIONS } from '../data/mockData';
import styles from './MessagesPage.module.css';

const MessagesPage: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <h1 className={styles.title}>Xabarlar</h1>
        <button className={styles.iconButton} type="button" aria-label="Yangi xabar">
          <PenSquare size={20} />
        </button>
      </div>

      {CONVERSATIONS.length === 0 ? (
        <div className={styles.empty}>
          <MessageCircle size={64} className={styles.emptyIcon} />
          <p className={styles.emptyText}>Xabarlar yo'q</p>
          <p className={styles.emptySubtext}>
            Sotuvchi bilan bog'lanish uchun e'lon sahifasiga o'ting
          </p>
          <Button variant="primary" onClick={() => navigate('/')}>
            E'lonlarni ko'rish
          </Button>
        </div>
      ) : (
        <div className={styles.list}>
          {CONVERSATIONS.map((conversation) => (
            <button
              key={conversation.id}
              className={styles.row}
              type="button"
              onClick={() => navigate(`/messages/${conversation.id}`)}
            >
              <div className={styles.avatar}>{conversation.avatar}</div>
              <div className={styles.info}>
                <span className={styles.name}>{conversation.name}</span>
                <span className={styles.lastMsg}>{conversation.lastMsg}</span>
              </div>
              <div className={styles.meta}>
                <span className={styles.time}>{conversation.time}</span>
                {conversation.unread > 0 && (
                  <span className={styles.unreadBadge}>{conversation.unread}</span>
                )}
              </div>
            </button>
          ))}
        </div>
      )}

      <BottomNav />
    </div>
  );
};

export default MessagesPage;
