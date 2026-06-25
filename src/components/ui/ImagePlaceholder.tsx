import React from 'react';
import styles from './ImagePlaceholder.module.css';

interface ImagePlaceholderProps {
  height?: number | string;
  radius?: string;
  className?: string;
  onClick?: () => void;
}

const ImagePlaceholder: React.FC<ImagePlaceholderProps> = ({
  height = 140,
  radius,
  className = '',
  onClick,
}) => {
  return (
    <div
      className={`imgPlaceholder ${styles.placeholder} ${className}`}
      style={{ height, borderRadius: radius }}
      onClick={onClick}
    />
  );
};

export default ImagePlaceholder;
