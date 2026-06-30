import React from 'react';

type P = { size?: number; color?: string; fill?: string; stroke?: number };
const base = (size = 20, color = 'currentColor', stroke = 2): React.SVGProps<SVGSVGElement> => ({
  width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
  stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round',
});

export const Back = (p: P) => (<svg {...base(p.size, p.color, 2.2)}><path d="M15 18l-6-6 6-6" /></svg>);
export const Close = (p: P) => (<svg {...base(p.size, p.color, 2.2)}><path d="M18 6L6 18M6 6l12 12" /></svg>);
export const Search = (p: P) => (<svg {...base(p.size, p.color)}><circle cx="11" cy="11" r="7" /><path d="M21 21l-4-4" /></svg>);
export const Filter = (p: P) => (<svg {...base(p.size, p.color)}><path d="M4 6h16M7 12h10M10 18h4" /></svg>);
export const Plus = (p: P) => (<svg {...base(p.size, p.color, 2.4)}><path d="M12 5v14M5 12h14" /></svg>);
export const Bell = (p: P) => (<svg {...base(p.size, p.color)}><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.7 21a2 2 0 0 1-3.4 0" /></svg>);
export const Grid = (p: P) => (<svg {...base(p.size, p.color)}><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></svg>);
export const Home = (p: P) => (<svg {...base(p.size, p.color)}><path d="M3 10.5L12 3l9 7.5" /><path d="M5 9.5V20h14V9.5" /></svg>);
export const User = (p: P) => (<svg {...base(p.size, p.color)}><circle cx="12" cy="8" r="4" /><path d="M4 21c0-4.4 4-6.5 8-6.5s8 2.1 8 6.5" /></svg>);
export const Pin = (p: P) => (<svg {...base(p.size, p.color)}><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z" /><circle cx="12" cy="10" r="3" /></svg>);
export const Chevron = (p: P) => (<svg {...base(p.size, p.color, 2)}><path d="M9 6l6 6-6 6" /></svg>);
export const ChevronDown = (p: P) => (<svg {...base(p.size, p.color, 2.2)}><path d="M6 9l6 6 6-6" /></svg>);
export const Phone = (p: P) => (<svg width={p.size || 18} height={p.size || 18} viewBox="0 0 24 24" fill={p.color || 'currentColor'}><path d="M6.6 10.8a15 15 0 0 0 6.6 6.6l2.2-2.2a1 1 0 0 1 1-.24 11 11 0 0 0 3.4.55 1 1 0 0 1 1 1V20a1 1 0 0 1-1 1A17 17 0 0 1 3 4a1 1 0 0 1 1-1h3.3a1 1 0 0 1 1 1 11 11 0 0 0 .55 3.4 1 1 0 0 1-.25 1z" /></svg>);
export const Chat = (p: P) => (<svg {...base(p.size, p.color)}><path d="M21 11.5a8.4 8.4 0 0 1-12 7.6L3 21l1.9-6A8.4 8.4 0 1 1 21 11.5z" /></svg>);
export const Send = (p: P) => (<svg width={p.size || 18} height={p.size || 18} viewBox="0 0 24 24" fill={p.color || 'currentColor'}><path d="M3 11l18-8-8 18-2-7-8-3z" /></svg>);
export const Star = (p: P) => (<svg width={p.size || 18} height={p.size || 18} viewBox="0 0 24 24" fill={p.fill || 'none'} stroke={p.color || 'currentColor'} strokeWidth={p.stroke || 2}><path d="M12 2l2.6 6.3L21 9l-5 4.3L17.5 20 12 16.4 6.5 20 8 13.3 3 9l6.4-.7z" /></svg>);
export const Heart = (p: P) => (<svg width={p.size || 18} height={p.size || 18} viewBox="0 0 24 24" fill={p.fill || 'none'} stroke={p.color || 'currentColor'} strokeWidth={p.stroke || 2}><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8z" /></svg>);
export const Shield = (p: P) => (<svg {...base(p.size, p.color)}><path d="M12 2l8 4v6c0 5-3.5 8-8 10-4.5-2-8-5-8-10V6z" /><path d="M9 12l2 2 4-4" /></svg>);
export const Truck = (p: P) => (<svg {...base(p.size, p.color)}><rect x="1" y="6" width="14" height="11" rx="1.5" /><path d="M15 9h4l3 3v5h-7" /><circle cx="6" cy="18" r="2" /><circle cx="18" cy="18" r="2" /></svg>);
export const Check = (p: P) => (<svg {...base(p.size, p.color, p.stroke || 2.4)}><path d="M5 12l5 5 9-11" /></svg>);
export const Verified = (p: P) => (<svg width={p.size || 14} height={p.size || 14} viewBox="0 0 24 24" fill={p.color || '#C2613B'} stroke="#fff" strokeWidth="2"><circle cx="12" cy="12" r="10" /><path d="M8 12l3 3 5-6" /></svg>);
export const Card = (p: P) => (<svg {...base(p.size, p.color)}><rect x="2" y="5" width="20" height="14" rx="2" /><path d="M2 10h20" /></svg>);
export const Lock = (p: P) => (<svg {...base(p.size, p.color)}><rect x="3" y="11" width="18" height="10" rx="2" /><path d="M7 11V7a5 5 0 0 1 10 0v4" /></svg>);
export const Tv = (p: P) => (<svg {...base(p.size, p.color)}><rect x="3" y="4" width="18" height="12" rx="2" /><path d="M8 20h8M12 16v4" /></svg>);
export const Tractor = (p: P) => (<svg {...base(p.size, p.color)}><circle cx="7" cy="17" r="3" /><circle cx="17" cy="17" r="3" /><path d="M10 17h4M4 17V9h6l3 4h4" /></svg>);
export const Wheat = (p: P) => (<svg {...base(p.size, p.color)}><path d="M12 3v18M12 7c-3 0-5-2-5-2M12 7c3 0 5-2 5-2M12 12c-3 0-5-2-5-2M12 12c3 0 5-2 5-2" /></svg>);
export const Drop = (p: P) => (<svg {...base(p.size, p.color)}><path d="M12 3c-3 0-5 2-5 5 0 4 5 13 5 13s5-9 5-13c0-3-2-5-5-5z" /></svg>);
export const Bag = (p: P) => (<svg {...base(p.size, p.color)}><rect x="3" y="7" width="18" height="13" rx="2" /><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" /></svg>);
export const Eye = (p: P) => (<svg {...base(p.size, p.color)}><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7z" /><circle cx="12" cy="12" r="3" /></svg>);
export const LogOut = (p: P) => (<svg {...base(p.size, p.color)}><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" /><polyline points="16 17 21 12 16 7" /><line x1="21" y1="12" x2="9" y2="12" /></svg>);

export const Logo = ({ size = 24, arch = '#C2613B', inner = '#F6EFE4', dot = '#E0A33E' }:
  { size?: number; arch?: string; inner?: string; dot?: string }) => (
  <svg width={size} height={size * 1.2} viewBox="0 0 100 120" fill="none">
    <path d="M22 112 L22 54 C22 32 34 17 50 9 C66 17 78 32 78 54 L78 112 Z" fill={arch} />
    <path d="M38 112 L38 60 C38 45 43 36 50 31 C57 36 62 45 62 60 L62 112 Z" fill={inner} />
    <circle cx="50" cy="22" r="7" fill={dot} />
  </svg>
);
