import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, Phone, Send } from 'lucide-react';
import type { ChatMessage } from '../data/mockData';
import { CONVERSATIONS, MOCK_MESSAGES } from '../data/mockData';
import styles from './MessageDetailPage.module.css';

const MessageDetailPage: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const conversation = CONVERSATIONS.find((c) => c.id === id) ?? CONVERSATIONS[0];

  const [messages, setMessages] = useState<ChatMessage[]>(MOCK_MESSAGES);
  const [input, setInput] = useState('');

  const handleSend = () => {
    const text = input.trim();
    if (!text) return;
    const time = new Date().toLocaleTimeString('uz-UZ', { hour: '2-digit', minute: '2-digit' });
    setMessages((prev) => [...prev, { id: prev.length + 1, from: 'me', text, time }]);
    setInput('');
  };

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <button className={styles.backButton} type="button" onClick={() => navigate(-1)}>
          <ArrowLeft size={20} />
        </button>
        <div className={styles.contact}>
          <div className={styles.avatar}>{conversation.avatar}</div>
          <div className={styles.contactInfo}>
            <span className={styles.name}>{conversation.name}</span>
            <span className={styles.status}>Online</span>
          </div>
        </div>
        <button className={styles.phoneButton} type="button" aria-label="Qo'ng'iroq">
          <Phone size={19} />
        </button>
      </div>

      <div className={styles.chatArea}>
        <span className={styles.dateSeparator}>Bugun</span>
        {messages.map((message) => (
          <div
            key={message.id}
            className={`${styles.messageRow} ${message.from === 'me' ? styles.sent : styles.received}`}
          >
            <div className={`${styles.bubble} ${message.from === 'me' ? styles.bubbleSent : styles.bubbleReceived}`}>
              {message.text}
            </div>
            <span className={styles.time}>{message.time}</span>
          </div>
        ))}
      </div>

      <div className={styles.inputBar}>
        <input
          className={styles.input}
          type="text"
          placeholder="Xabar yozing..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleSend()}
        />
        <button className={styles.sendButton} type="button" onClick={handleSend} aria-label="Yuborish">
          <Send size={18} color="#fff" />
        </button>
      </div>
    </div>
  );
};

export default MessageDetailPage;
