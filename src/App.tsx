import React, { useState, useEffect, useMemo } from 'react';
import { 
  Home, 
  Search, 
  PlusCircle, 
  Heart, 
  User, 
  Tractor, 
  Sprout, 
  Laptop, 
  Building2, 
  MapPin, 
  Phone, 
  ArrowLeft, 
  Share2, 
  Bell, 
  Eye, 
  Calendar, 
  Database, 
  Activity, 
  Trash2, 
  Users, 
  TrendingUp, 
  X, 
  ChevronRight,
  Sparkles,
  CheckCircle2,
  PhoneCall
} from 'lucide-react';
import { CATEGORIES, INITIAL_LISTINGS } from './mockData';
import type { Listing } from './mockData';
import './App.css';

// Custom high-fidelity SVG representations for listings
const ListingImage: React.FC<{ type: string; className?: string }> = ({ type, className }) => {
  const getIllustration = () => {
    switch (type) {
      case 'apartment':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="skyGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#0EA5E9" />
                <stop offset="100%" stopColor="#0369A1" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#skyGrad)" />
            {/* Ground */}
            <rect x="0" y="80" width="100" height="20" fill="#0A2540" />
            {/* Buildings */}
            <rect x="15" y="30" width="30" height="50" fill="#FFFFFF" rx="2" />
            <rect x="50" y="20" width="35" height="60" fill="#E2E8F0" rx="2" />
            {/* Windows */}
            <rect x="20" y="38" width="8" height="8" fill="#0EA5E9" rx="1" />
            <rect x="32" y="38" width="8" height="8" fill="#0EA5E9" rx="1" />
            <rect x="20" y="52" width="8" height="8" fill="#0EA5E9" rx="1" />
            <rect x="32" y="52" width="8" height="8" fill="#0EA5E9" rx="1" />
            <rect x="20" y="66" width="8" height="8" fill="#0EA5E9" rx="1" />
            <rect x="32" y="66" width="8" height="8" fill="#0EA5E9" rx="1" />

            <rect x="56" y="28" width="10" height="10" fill="#0A2540" rx="1" />
            <rect x="70" y="28" width="10" height="10" fill="#0A2540" rx="1" />
            <rect x="56" y="44" width="10" height="10" fill="#0A2540" rx="1" />
            <rect x="70" y="44" width="10" height="10" fill="#0A2540" rx="1" />
            <rect x="56" y="60" width="10" height="10" fill="#0A2540" rx="1" />
            <rect x="70" y="60" width="10" height="10" fill="#0A2540" rx="1" />
          </svg>
        );
      case 'drone':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="droneGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#8B5CF6" />
                <stop offset="100%" stopColor="#4C1D95" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#droneGrad)" />
            {/* Drone body */}
            <circle cx="50" cy="50" r="14" fill="#FFFFFF" />
            <circle cx="50" cy="50" r="8" fill="#0A2540" />
            {/* Rotor Arms */}
            <line x1="25" y1="25" x2="75" y2="75" stroke="#FFFFFF" strokeWidth="4" />
            <line x1="25" y1="75" x2="75" y2="25" stroke="#FFFFFF" strokeWidth="4" />
            {/* Motors */}
            <circle cx="25" cy="25" r="5" fill="#3B82F6" />
            <circle cx="75" cy="75" r="5" fill="#3B82F6" />
            <circle cx="25" cy="75" r="5" fill="#3B82F6" />
            <circle cx="75" cy="25" r="5" fill="#3B82F6" />
            {/* Propellers */}
            <ellipse cx="25" cy="25" rx="10" ry="2" fill="#E2E8F0" opacity="0.8" />
            <ellipse cx="75" cy="75" rx="10" ry="2" fill="#E2E8F0" opacity="0.8" />
            <ellipse cx="25" cy="75" rx="10" ry="2" fill="#E2E8F0" opacity="0.8" />
            <ellipse cx="75" cy="25" rx="10" ry="2" fill="#E2E8F0" opacity="0.8" />
            {/* Spray nozzle drops */}
            <circle cx="50" cy="72" r="3" fill="#38BDF8" />
            <circle cx="45" cy="78" r="2" fill="#38BDF8" opacity="0.7" />
            <circle cx="55" cy="78" r="2" fill="#38BDF8" opacity="0.7" />
          </svg>
        );
      case 'tractor':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="tracGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#0077B6" />
                <stop offset="100%" stopColor="#00B4D8" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#tracGrad)" />
            {/* Ground */}
            <rect x="0" y="75" width="100" height="25" fill="#1E293B" />
            {/* Tractor body */}
            <rect x="30" y="45" width="35" height="20" fill="#10B981" rx="2" />
            <rect x="42" y="32" width="20" height="15" fill="#FFFFFF" rx="2" />
            <rect x="45" y="35" width="14" height="10" fill="#0A2540" />
            {/* Exhaust pipe */}
            <line x1="36" y1="45" x2="36" y2="25" stroke="#FFFFFF" strokeWidth="2" />
            <path d="M36,25 L39,23" stroke="#FFFFFF" strokeWidth="2" />
            {/* Wheels */}
            <circle cx="35" cy="70" r="10" fill="#000000" stroke="#FFFFFF" strokeWidth="2" />
            <circle cx="35" cy="70" r="4" fill="#E2E8F0" />
            <circle cx="62" cy="65" r="14" fill="#000000" stroke="#FFFFFF" strokeWidth="2" />
            <circle cx="62" cy="65" r="6" fill="#E2E8F0" />
          </svg>
        );
      case 'cow':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="cowGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#10B981" />
                <stop offset="100%" stopColor="#047857" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#cowGrad)" />
            {/* Cow head shape */}
            <rect x="30" y="35" width="40" height="30" fill="#FFFFFF" rx="10" />
            <rect x="35" y="55" width="30" height="18" fill="#F472B6" rx="8" />
            {/* Spots */}
            <path d="M30,40 Q35,45 32,50 Z" fill="#1E293B" />
            <path d="M65,38 Q60,42 68,48 Z" fill="#1E293B" />
            {/* Ears */}
            <path d="M22,35 Q28,30 28,40 Z" fill="#FFFFFF" />
            <path d="M78,35 Q72,30 72,40 Z" fill="#FFFFFF" />
            {/* Horns */}
            <path d="M32,36 Q30,22 36,26 Z" fill="#E2E8F0" />
            <path d="M68,36 Q70,22 64,26 Z" fill="#E2E8F0" />
            {/* Eyes */}
            <circle cx="42" cy="46" r="3" fill="#1E293B" />
            <circle cx="58" cy="46" r="3" fill="#1E293B" />
            {/* Muzzle */}
            <circle cx="44" cy="62" r="2" fill="#9D174D" />
            <circle cx="56" cy="62" r="2" fill="#9D174D" />
          </svg>
        );
      case 'rice':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="riceGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#F59E0B" />
                <stop offset="100%" stopColor="#D97706" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#riceGrad)" />
            {/* Sack outline */}
            <path d="M30,75 L30,40 Q50,32 70,40 L70,75 Q50,85 30,75 Z" fill="#F5F5F4" stroke="#D7CCC8" strokeWidth="2" />
            {/* Sack tie rope */}
            <ellipse cx="50" cy="42" rx="21" ry="3" fill="#8D6E63" />
            {/* Logo on sack */}
            <circle cx="50" cy="58" r="9" fill="#059669" />
            <path d="M50,52 Q53,58 50,64 Q47,58 50,52 Z" fill="#FFFFFF" />
            {/* Ears of wheat sticking out */}
            <path d="M35,38 Q25,20 18,22" stroke="#FBBF24" strokeWidth="2" fill="none" />
            <path d="M65,38 Q75,20 82,22" stroke="#FBBF24" strokeWidth="2" fill="none" />
          </svg>
        );
      case 'macbook':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="macGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#4F46E5" />
                <stop offset="100%" stopColor="#312E81" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#macGrad)" />
            {/* Screen */}
            <rect x="22" y="28" width="56" height="36" fill="#1E293B" rx="3" stroke="#94A3B8" strokeWidth="2" />
            <rect x="25" y="31" width="50" height="30" fill="#0F172A" />
            {/* Screen content */}
            <rect x="29" y="35" width="12" height="4" fill="#10B981" rx="1" />
            <rect x="29" y="42" width="22" height="3" fill="#8B5CF6" rx="1" />
            <rect x="29" y="48" width="18" height="3" fill="#3B82F6" rx="1" />
            {/* Laptop Base */}
            <rect x="14" y="64" width="72" height="4" fill="#94A3B8" rx="1" />
            <polygon points="20,68 80,68 76,73 24,73" fill="#64748B" />
          </svg>
        );
      case 'poultry':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="poultGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#10B981" />
                <stop offset="100%" stopColor="#047857" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#poultGrad)" />
            {/* Shell bottom */}
            <path d="M25,60 Q50,90 75,60 Q60,65 50,60 Q40,65 25,60 Z" fill="#F5F5F4" stroke="#E2E8F0" strokeWidth="2" />
            {/* Chick head */}
            <circle cx="50" cy="45" r="16" fill="#FBBF24" />
            {/* Chick eyes */}
            <circle cx="44" cy="42" r="2" fill="#000000" />
            <circle cx="56" cy="42" r="2" fill="#000000" />
            {/* Beak */}
            <polygon points="50,45 46,49 54,49" fill="#F97316" />
            {/* Hatch shell top */}
            <path d="M36,32 Q50,15 64,32 Q54,34 50,30 Q46,34 36,32 Z" fill="#F5F5F4" stroke="#E2E8F0" strokeWidth="2" />
          </svg>
        );
      case 'irrigation':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="irrGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#0EA5E9" />
                <stop offset="100%" stopColor="#0284C7" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#irrGrad)" />
            {/* Pipes and water drops */}
            <line x1="0" y1="50" x2="100" y2="50" stroke="#E2E8F0" strokeWidth="6" />
            <line x1="20" y1="50" x2="20" y2="75" stroke="#E2E8F0" strokeWidth="4" />
            <line x1="55" y1="50" x2="55" y2="75" stroke="#E2E8F0" strokeWidth="4" />
            <line x1="85" y1="50" x2="85" y2="75" stroke="#E2E8F0" strokeWidth="4" />
            {/* Sprinkler heads */}
            <rect x="16" y="73" width="8" height="5" fill="#64748B" />
            <rect x="51" y="73" width="8" height="5" fill="#64748B" />
            <rect x="81" y="73" width="8" height="5" fill="#64748B" />
            {/* Water Drops */}
            <circle cx="12" cy="83" r="2" fill="#E0F2FE" />
            <circle cx="28" cy="83" r="2" fill="#E0F2FE" />
            <circle cx="47" cy="83" r="2" fill="#E0F2FE" />
            <circle cx="63" cy="83" r="2" fill="#E0F2FE" />
            {/* Crops growing */}
            <path d="M10,95 Q12,87 18,90" stroke="#10B981" strokeWidth="2" fill="none" />
            <path d="M28,95 Q30,87 36,90" stroke="#10B981" strokeWidth="2" fill="none" />
            <path d="M48,95 Q50,87 56,90" stroke="#10B981" strokeWidth="2" fill="none" />
          </svg>
        );
      case 'sheep':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id="sheepGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#10B981" />
                <stop offset="100%" stopColor="#059669" />
              </linearGradient>
            </defs>
            <rect width="100" height="100" fill="url(#sheepGrad)" />
            {/* Fluffy sheep body */}
            <circle cx="40" cy="50" r="14" fill="#FFFFFF" />
            <circle cx="54" cy="46" r="12" fill="#FFFFFF" />
            <circle cx="48" cy="58" r="13" fill="#FFFFFF" />
            <circle cx="60" cy="56" r="11" fill="#FFFFFF" />
            {/* Head */}
            <rect x="62" y="38" width="16" height="18" fill="#1E293B" rx="8" />
            {/* Horn */}
            <path d="M68,36 Q64,28 72,28" stroke="#D7CCC8" strokeWidth="3" fill="none" />
            {/* Eyes */}
            <circle cx="70" cy="44" r="1.5" fill="#FFFFFF" />
            {/* Legs */}
            <line x1="38" y1="65" x2="38" y2="78" stroke="#1E293B" strokeWidth="3" />
            <line x1="48" y1="65" x2="48" y2="78" stroke="#1E293B" strokeWidth="3" />
            <line x1="56" y1="65" x2="56" y2="78" stroke="#1E293B" strokeWidth="3" />
            <line x1="64" y1="65" x2="64" y2="78" stroke="#1E293B" strokeWidth="3" />
          </svg>
        );
      default:
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <rect width="100" height="100" fill="#E2E8F0" />
            <circle cx="50" cy="50" r="20" fill="#94A3B8" />
          </svg>
        );
    }
  };

  return <div className={`w-full h-full ${className || ''}`}>{getIllustration()}</div>;
};

// Types for presentation console logs
interface DevLog {
  id: string;
  time: string;
  message: string;
  type: 'info' | 'success' | 'call' | 'fav';
}

// Simulated active profiles
interface SimulatedUser {
  name: string;
  phone: string;
  role: string;
  avatar: string;
  balance: string;
  listingsPosted: number;
  sellerType: 'Individual' | 'Company';
}

const MOCK_USERS: SimulatedUser[] = [
  {
    name: 'Bobur Dehqon',
    phone: '+998 97 765 43 21',
    role: 'Dehqon (Local Farmer)',
    avatar: 'BD',
    balance: '1,250,000 UZS',
    listingsPosted: 4,
    sellerType: 'Individual'
  },
  {
    name: 'Alice Vance',
    phone: '+998 90 999 88 77',
    role: 'Smart Agrotech CEO',
    avatar: 'AV',
    balance: '$4,800 USD',
    listingsPosted: 8,
    sellerType: 'Company'
  }
];

export default function App() {
  // --- STATE FOR MAIN APP DB ---
  const [listings, setListings] = useState<Listing[]>(() => {
    const saved = localStorage.getItem('nv_elon_listings');
    return saved ? JSON.parse(saved) : INITIAL_LISTINGS;
  });

  // Sync back to localStorage
  useEffect(() => {
    localStorage.setItem('nv_elon_listings', JSON.stringify(listings));
  }, [listings]);

  // --- STATE FOR MOCK SIMULATION ENVIRONMENT ---
  const [activeUserIndex, setActiveUserIndex] = useState<number>(0);
  const currentUser = MOCK_USERS[activeUserIndex];

  const [devLogs, setDevLogs] = useState<DevLog[]>([
    {
      id: '1',
      time: '17:11:15',
      message: 'System initialized. 9 mock ads loaded successfully.',
      type: 'info'
    }
  ]);
  const [activeInspectorTab, setActiveInspectorTab] = useState<'state' | 'logs'>('logs');

  const addLog = (message: string, type: 'info' | 'success' | 'call' | 'fav' = 'info') => {
    const timeStr = new Date().toLocaleTimeString('en-US', { hour12: false });
    setDevLogs(prev => [
      {
        id: Math.random().toString(),
        time: timeStr,
        message,
        type
      },
      ...prev
    ]);
  };

  // Switch Simulated User
  const handleUserChange = (index: number) => {
    setActiveUserIndex(index);
    addLog(`Switched active simulator profile to ${MOCK_USERS[index].name}`, 'info');
  };

  // Clear local storage and reset mock db
  const handleResetDb = () => {
    localStorage.removeItem('nv_elon_listings');
    setListings(INITIAL_LISTINGS);
    setFavorites(new Set());
    addLog('Database reset to defaults. Cleaned cache.', 'info');
  };

  // --- STATE FOR PHONE EMULATOR ---
  const [currentScreen, setCurrentScreen] = useState<'home' | 'categories' | 'add' | 'favorites' | 'profile'>('home');
  const [selectedListingId, setSelectedListingId] = useState<string | null>(null);
  const [favorites, setFavorites] = useState<Set<string>>(new Set());

  // Filters inside emulator
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [selectedSubcategory, setSelectedSubcategory] = useState<string>('all');
  const [selectedLocation, setSelectedLocation] = useState<string>('Barchasi');

  // New Ad Listing Form State
  const [newAdTitle, setNewAdTitle] = useState('');
  const [newAdDesc, setNewAdDesc] = useState('');
  const [newAdCat, setNewAdCat] = useState('real-estate');
  const [newAdSubcat, setNewAdSubcat] = useState('');
  const [newAdPrice, setNewAdPrice] = useState('');
  const [newAdLocation, setNewAdLocation] = useState('Tashkent');
  const [newAdPhone, setNewAdPhone] = useState(currentUser.phone);

  // Sync form phone with active user profile when active profile changes
  useEffect(() => {
    setNewAdPhone(currentUser.phone);
  }, [currentUser]);

  // Set default subcategory when form category changes
  useEffect(() => {
    const subcats = CATEGORIES.find(c => c.id === newAdCat)?.subcategories;
    if (subcats && subcats.length > 0) {
      setNewAdSubcat(subcats[0].id);
    }
  }, [newAdCat]);

  // Calling Phone Overlay State
  const [activeCall, setActiveCall] = useState<Listing | null>(null);
  const [callStatus, setCallStatus] = useState<'ringing' | 'connected' | 'ended'>('ringing');
  const [callTimer, setCallTimer] = useState(0);

  // Real-time top screen clock simulation
  const [timeText, setTimeText] = useState('17:11');
  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      let hrs = now.getHours().toString().padStart(2, '0');
      let mins = now.getMinutes().toString().padStart(2, '0');
      setTimeText(`${hrs}:${mins}`);
    };
    updateTime();
    const interval = setInterval(updateTime, 10000);
    return () => clearInterval(interval);
  }, []);

  // Notification Banner
  const [notification, setNotification] = useState<{ title: string; desc: string } | null>(null);
  const showNotification = (title: string, desc: string) => {
    setNotification({ title, desc });
    setTimeout(() => {
      setNotification(null);
    }, 4000);
  };

  // Calling logic
  useEffect(() => {
    let timerInterval: any;
    if (activeCall && callStatus === 'ringing') {
      const ringTimer = setTimeout(() => {
        setCallStatus('connected');
        addLog(`Call established with ${activeCall.sellerName} (${activeCall.phone})`, 'call');
      }, 1500);
      return () => clearTimeout(ringTimer);
    } else if (activeCall && callStatus === 'connected') {
      timerInterval = setInterval(() => {
        setCallTimer(prev => prev + 1);
      }, 1000);
    }
    return () => clearInterval(timerInterval);
  }, [activeCall, callStatus]);

  const handleStartCall = (listing: Listing) => {
    setActiveCall(listing);
    setCallStatus('ringing');
    setCallTimer(0);
    addLog(`Initiating call simulation to ${listing.sellerName} regarding: "${listing.title}"`, 'info');
  };

  const handleEndCall = () => {
    if (activeCall) {
      addLog(`Call with ${activeCall.sellerName} ended. Duration: ${callTimer}s`, 'info');
    }
    setActiveCall(null);
    setCallStatus('ringing');
    setCallTimer(0);
  };

  // Toggle favorite
  const handleToggleFavorite = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    const newFavs = new Set(favorites);
    const item = listings.find(l => l.id === id);
    if (newFavs.has(id)) {
      newFavs.delete(id);
      addLog(`Removed from Favorites: "${item?.title}"`, 'fav');
    } else {
      newFavs.add(id);
      addLog(`Added to Favorites: "${item?.title}"`, 'fav');
      showNotification('Saralanganlarga qo\'shildi', item?.title || '');
    }
    setFavorites(newFavs);
  };

  // Form Submit Listing
  const handlePostAdSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!newAdTitle || !newAdPrice || !newAdDesc) {
      alert('Please fill all fields');
      return;
    }

    // Assign appropriate vector illustration tag
    let imageTag = 'default';
    if (newAdCat === 'real-estate') {
      imageTag = 'apartment';
    } else if (newAdCat === 'electronics') {
      imageTag = newAdTitle.toLowerCase().includes('macbook') ? 'macbook' : 'drone';
    } else if (newAdCat === 'commercial-farming') {
      imageTag = newAdTitle.toLowerCase().includes('tractor') ? 'tractor' : 'irrigation';
    } else if (newAdCat === 'local-farming') {
      if (newAdSubcat === 'livestock') imageTag = 'cow';
      else if (newAdSubcat === 'grains') imageTag = 'rice';
      else imageTag = 'poultry';
    }

    const newAd: Listing = {
      id: (listings.length + 1).toString(),
      title: newAdTitle,
      description: newAdDesc,
      price: parseFloat(newAdPrice),
      currency: 'USD',
      category: newAdCat,
      subcategory: newAdSubcat,
      location: newAdLocation,
      phone: newAdPhone,
      date: 'Hozirgina',
      image: imageTag,
      views: 0,
      sellerName: currentUser.name,
      sellerType: currentUser.sellerType,
      status: 'active'
    };

    setListings(prev => [newAd, ...prev]);
    addLog(`New ad posted successfully: "${newAdTitle}" under ${newAdCat}`, 'success');
    showNotification('E\'lon joylashtirildi!', newAdTitle);
    
    // reset form
    setNewAdTitle('');
    setNewAdDesc('');
    setNewAdPrice('');
    
    // go to home screen
    setCurrentScreen('home');
  };

  // --- DERIVED FEED FILTERING ---
  const filteredListings = useMemo(() => {
    return listings.filter(item => {
      // 1. Search Query
      const matchesSearch = searchQuery === '' || 
        item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.description.toLowerCase().includes(searchQuery.toLowerCase());
      
      // 2. Main Category
      const matchesCategory = selectedCategory === 'all' || item.category === selectedCategory;
      
      // 3. Subcategory
      const matchesSubcategory = selectedSubcategory === 'all' || item.subcategory === selectedSubcategory;
      
      // 4. Location
      const matchesLocation = selectedLocation === 'Barchasi' || item.location.includes(selectedLocation);

      return matchesSearch && matchesCategory && matchesSubcategory && matchesLocation;
    });
  }, [listings, searchQuery, selectedCategory, selectedSubcategory, selectedLocation]);

  // Selected Listing Detail Object
  const selectedListing = useMemo(() => {
    if (!selectedListingId) return null;
    return listings.find(l => l.id === selectedListingId) || null;
  }, [listings, selectedListingId]);

  return (
    <div className="dashboard-wrapper">
      {/* =========================================
         LEFT COLUMN: PRESENTATION & STATE INSPECTOR
         ========================================= */}
      <aside className="dashboard-sidebar">
        <div className="brand-container">
          <div className="logo-badge">nv</div>
          <div>
            <div className="brand-text">nv.elon</div>
            <div className="brand-tagline">Tech & Agriculture Classifieds</div>
          </div>
        </div>

        <section className="intro-section">
          <h1>Modern Marketplace Ecosystem</h1>
          <p>
            An interactive simulator demonstrating a high-fidelity classifieds portal specifically optimized for Uzbek tech startups and B2B/B2C agricultural markets. Experience real-time reactivity inside the mobile handset emulator on the right.
          </p>
          <div className="tech-stack-pills">
            <span className="pill blue">React 18</span>
            <span className="pill green">Vanilla CSS</span>
            <span className="pill purple">TypeScript</span>
            <span className="pill gray">State Persisted</span>
          </div>
        </section>

        {/* Simulator User Session Toggler */}
        <section className="panel-card">
          <h3>
            <Users size={18} />
            Simulator User Sessions
          </h3>
          <p style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '-8px' }}>
            Toggle between the two profiles below to test posting ads, viewing user dashboards, and simulation workflows.
          </p>
          <div className="session-user-selector">
            {MOCK_USERS.map((user, idx) => (
              <button
                key={idx}
                className={`user-selector-btn ${activeUserIndex === idx ? 'active' : ''}`}
                onClick={() => handleUserChange(idx)}
              >
                <span className="name">{user.name}</span>
                <span className="role">{user.role}</span>
                <span style={{ fontSize: '10px', color: 'var(--primary-soft)', fontWeight: 'bold' }}>
                  {user.balance}
                </span>
              </button>
            ))}
          </div>
        </section>

        {/* Live System Stats */}
        <section className="panel-card">
          <h3>
            <TrendingUp size={18} />
            Live Marketplace Metrics
          </h3>
          <div className="stats-grid">
            <div className="stat-box">
              <div className="stat-val">{listings.length}</div>
              <div className="stat-lbl">Active Ads</div>
            </div>
            <div className="stat-box">
              <div className="stat-val">{favorites.size}</div>
              <div className="stat-lbl">User Saved</div>
            </div>
            <div className="stat-box">
              <div className="stat-val">
                {listings.filter(l => l.category === 'local-farming' || l.category === 'commercial-farming').length}
              </div>
              <div className="stat-lbl">Agri Ads</div>
            </div>
          </div>
        </section>

        {/* State Inspector & Event Console */}
        <section className="panel-card" style={{ flexGrow: 1, minHeight: '320px' }}>
          <div className="inspector-tabs">
            <button
              className={`inspector-tab ${activeInspectorTab === 'logs' ? 'active' : ''}`}
              onClick={() => setActiveInspectorTab('logs')}
            >
              <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Activity size={14} /> Console Event Stream
              </span>
            </button>
            <button
              className={`inspector-tab ${activeInspectorTab === 'state' ? 'active' : ''}`}
              onClick={() => setActiveInspectorTab('state')}
            >
              <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Database size={14} /> React DB Inspector
              </span>
            </button>
          </div>

          {activeInspectorTab === 'logs' ? (
            <div className="log-list">
              {devLogs.map(log => (
                <div key={log.id} className="log-item" style={{ 
                  borderLeftColor: log.type === 'success' ? 'var(--agri-green)' : 
                                  log.type === 'call' ? 'var(--primary-soft)' :
                                  log.type === 'fav' ? '#EF4444' : 'var(--text-muted)'
                }}>
                  <div>
                    <span className="log-time">[{log.time}]</span>{' '}
                    <span style={{ fontWeight: 500 }}>{log.message}</span>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="code-container">
              {JSON.stringify(
                {
                  activeUser: currentUser.name,
                  activeUserRole: currentUser.role,
                  currentHandsetScreen: currentScreen,
                  viewingAdId: selectedListingId || 'None',
                  searchFilter: { searchQuery, selectedCategory, selectedSubcategory, selectedLocation },
                  savedAdsCount: favorites.size,
                  totalLiveAdsCount: listings.length,
                  listingsSummary: listings.map(l => ({ id: l.id, title: l.title, cat: l.category, price: l.price }))
                },
                null,
                2
              )}
            </div>
          )}

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: 'auto', paddingTop: '10px', borderTop: '1px solid var(--border-light)' }}>
            <button 
              onClick={handleResetDb} 
              style={{ fontSize: '11px', display: 'flex', alignItems: 'center', gap: '4px', color: '#EF4444', fontWeight: 600 }}
            >
              <Trash2 size={12} /> Clear Cache & Reset
            </button>
          </div>
        </section>
      </aside>

      {/* =========================================
         RIGHT COLUMN: PHONE VISUALIZER / EMULATOR
         ========================================= */}
      <main className="dashboard-visualizer">
        <div className="phone-emulator-container">
          <div className="phone-frame">
            {/* Physical Buttons on casing */}
            <div className="phone-btn vol-up"></div>
            <div className="phone-btn vol-down"></div>
            <div className="phone-btn power"></div>

            <div className="phone-screen">
              {/* Top notch system */}
              <div className="phone-notch-container">
                <div className={`dynamic-island ${notification ? 'active' : ''}`}>
                  <div className="island-camera"></div>
                  {notification ? (
                    <span className="island-alert-text">
                      🔔 {notification.title}: {notification.desc.substring(0, 15)}...
                    </span>
                  ) : (
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <div className="island-sensor"></div>
                    </div>
                  )}
                  <div className="island-sensor"></div>
                </div>
              </div>

              {/* Status Bar */}
              <div className="phone-status-bar">
                <div>{timeText}</div>
                <div className="status-right">
                  {/* Cellular network bar icon */}
                  <svg viewBox="0 0 24 24" fill="currentColor"><path d="M2 22h20V2z"/></svg>
                  {/* Wi-Fi Icon */}
                  <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 21l-12-12c5-5 19-5 24 0z"/></svg>
                  {/* Battery Icon */}
                  <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17 5H3a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2zM21 9h2v6h-2z"/></svg>
                </div>
              </div>

              {/* HANDSET APP SHELL */}
              <div className="app-shell">
                
                {/* 1. HOME SCREEN */}
                {currentScreen === 'home' && !selectedListingId && (
                  <>
                    <header className="app-header">
                      <div className="app-title-container">
                        <span className="app-logo">nv.elon</span>
                        <div className="location-picker">
                          <MapPin size={10} />
                          <select 
                            value={selectedLocation} 
                            onChange={(e) => {
                              setSelectedLocation(e.target.value);
                              addLog(`Filter location changed to: ${e.target.value}`, 'info');
                            }}
                            style={{ border: 'none', background: 'transparent', fontSize: '10px', fontWeight: 'bold', color: 'var(--text-dark)', cursor: 'pointer', outline: 'none' }}
                          >
                            <option value="Barchasi">O'zbekiston (Barchasi)</option>
                            <option value="Tashkent">Toshkent sh.</option>
                            <option value="Samarkand">Samarqand vil.</option>
                            <option value="Fergana">Farg'ona vil.</option>
                            <option value="Jizzakh">Jizzax vil.</option>
                            <option value="Khorezm">Xorazm vil.</option>
                            <option value="Namangan">Namangan vil.</option>
                            <option value="Bukhara">Buxoro vil.</option>
                          </select>
                        </div>
                      </div>
                      <button className="header-action flex-center" onClick={() => {
                        addLog('Notification Center opened', 'info');
                        showNotification('Xabarnomalar', 'Hozircha yangiliklar yo\'q');
                      }}>
                        <Bell size={16} />
                      </button>
                    </header>

                    {/* Search and Filters Bar */}
                    <div className="search-container">
                      <div className="search-input-wrapper">
                        <Search />
                        <input 
                          type="text" 
                          placeholder="Qidiruv (masalan: Traktor, iPhone)..." 
                          className="search-input"
                          value={searchQuery}
                          onChange={(e) => {
                            setSearchQuery(e.target.value);
                            if(e.target.value) addLog(`Typing search query: "${e.target.value}"`, 'info');
                          }}
                        />
                        {searchQuery && (
                          <button 
                            onClick={() => setSearchQuery('')}
                            style={{ position: 'absolute', right: '10px', color: 'var(--text-muted)' }}
                          >
                            <X size={14} />
                          </button>
                        )}
                      </div>
                    </div>

                    {/* Categories Pill Navigation */}
                    <div className="home-categories-bar">
                      <button 
                        className={`category-chip ${selectedCategory === 'all' ? 'active' : ''}`}
                        onClick={() => {
                          setSelectedCategory('all');
                          setSelectedSubcategory('all');
                          addLog('Category filter cleared', 'info');
                        }}
                      >
                        Barchasi
                      </button>
                      {CATEGORIES.map(cat => (
                        <button
                          key={cat.id}
                          className={`category-chip ${selectedCategory === cat.id ? `active-category-${cat.id}` : ''}`}
                          onClick={() => {
                            setSelectedCategory(cat.id);
                            setSelectedSubcategory('all');
                            addLog(`Filtered by category: ${cat.name}`, 'info');
                          }}
                        >
                          {cat.uzName}
                        </button>
                      ))}
                    </div>

                    {/* Subcategories Selector (Dynamic) */}
                    {selectedCategory !== 'all' && (
                      <div className="subcategories-container">
                        <button 
                          className={`sub-chip ${selectedSubcategory === 'all' ? 'active' : ''}`}
                          onClick={() => {
                            setSelectedSubcategory('all');
                          }}
                        >
                          Barcha {CATEGORIES.find(c=>c.id === selectedCategory)?.uzName}
                        </button>
                        {CATEGORIES.find(c => c.id === selectedCategory)?.subcategories?.map(sub => (
                          <button
                            key={sub.id}
                            className={`sub-chip ${selectedSubcategory === sub.id ? 'active' : ''}`}
                            onClick={() => {
                              setSelectedSubcategory(sub.id);
                              addLog(`Filtered by subcategory: ${sub.name}`, 'info');
                            }}
                          >
                            {sub.uzName}
                          </button>
                        ))}
                      </div>
                    )}

                    {/* Main Feed Viewport */}
                    <div className="screen-viewport">
                      
                      {/* Interactive Welcome Banner */}
                      <div className="hero-banner">
                        <div className="banner-title">nv.elon Agro-Tech</div>
                        <div className="banner-subtitle">Qishloq xo'jaligi va elektronika bozori</div>
                        <Sparkles className="banner-icon-bg" />
                      </div>

                      <div className="feed-header">
                        <span className="feed-title">
                          {selectedCategory === 'all' ? "Barcha e'lonlar" : CATEGORIES.find(c=>c.id === selectedCategory)?.uzName}
                        </span>
                        <span style={{ fontSize: '10px', color: 'var(--text-muted)' }}>
                          {filteredListings.length} ta e'lon topildi
                        </span>
                      </div>

                      {filteredListings.length === 0 ? (
                        <div style={{ padding: '40px 20px', textAlign: 'center', color: 'var(--text-muted)' }}>
                          <Search size={32} style={{ marginBottom: '10px' }} />
                          <p style={{ fontSize: '13px', fontWeight: 'bold' }}>Hech narsa topilmadi</p>
                          <p style={{ fontSize: '11px' }}>Qidiruv shartlarini o'zgartirib ko'ring</p>
                        </div>
                      ) : (
                        <div className="feed-grid">
                          {filteredListings.map(item => (
                            <div 
                              key={item.id} 
                              className="listing-card"
                              onClick={() => {
                                setSelectedListingId(item.id);
                                addLog(`Opening detailed view for: "${item.title}"`, 'info');
                              }}
                            >
                              <div className="card-image-wrapper">
                                <ListingImage type={item.image} />
                                <span className={`sector-badge ${
                                  item.category === 'electronics' ? 'tech' : 
                                  item.category === 'real-estate' ? 'real-estate' : 'agriculture'
                                }`}>
                                  {item.category === 'electronics' ? 'Tech' : 
                                   item.category === 'real-estate' ? 'Uy-joy' : 'Agro'}
                                </span>
                                <button 
                                  className={`favorite-btn flex-center ${favorites.has(item.id) ? 'active' : ''}`}
                                  onClick={(e) => handleToggleFavorite(item.id, e)}
                                >
                                  <Heart size={14} fill={favorites.has(item.id) ? 'currentColor' : 'none'} />
                                </button>
                              </div>
                              <div className="card-body">
                                <span className="card-category-text">
                                  {CATEGORIES.find(c => c.id === item.category)?.uzName}
                                </span>
                                <h4 className="card-title">{item.title}</h4>
                                <div className="card-location">
                                  <MapPin size={10} />
                                  <span>{item.location.split(',')[0]}</span>
                                </div>
                                <div className="card-footer">
                                  <span className="card-price">
                                    {item.price.toLocaleString()} {item.currency}
                                  </span>
                                  <button 
                                    className="card-call-btn flex-center"
                                    onClick={(e) => {
                                      e.stopPropagation();
                                      handleStartCall(item);
                                    }}
                                  >
                                    <Phone size={11} fill="currentColor" />
                                  </button>
                                </div>
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  </>
                )}

                {/* 2. CATEGORY BROWSER SCREEN */}
                {currentScreen === 'categories' && !selectedListingId && (
                  <>
                    <header className="post-ad-header">
                      <h2>Ruknlar bo'limi</h2>
                    </header>
                    <div className="screen-viewport category-browser-viewport">
                      {CATEGORIES.map(cat => (
                        <div key={cat.id} className="category-row-item">
                          <div 
                            className="category-row-header"
                            onClick={() => {
                              setSelectedCategory(cat.id);
                              setCurrentScreen('home');
                              addLog(`Category selected via browser: ${cat.name}`, 'info');
                            }}
                          >
                            <div className="category-row-title-info">
                              <div className={`category-row-icon-box flex-center ${cat.id}`}>
                                {cat.id === 'real-estate' && <Building2 size={16} />}
                                {cat.id === 'electronics' && <Laptop size={16} />}
                                {cat.id === 'commercial-farming' && <Tractor size={16} />}
                                {cat.id === 'local-farming' && <Sprout size={16} />}
                              </div>
                              <div>
                                <div className="category-row-name">{cat.uzName}</div>
                                <div className="category-row-subname">{cat.name}</div>
                              </div>
                            </div>
                            <ChevronRight size={16} style={{ color: 'var(--text-muted)' }} />
                          </div>
                          <div className="category-sub-list">
                            {cat.subcategories?.map(sub => (
                              <button
                                key={sub.id}
                                className="category-sub-item"
                                onClick={() => {
                                  setSelectedCategory(cat.id);
                                  setSelectedSubcategory(sub.id);
                                  setCurrentScreen('home');
                                  addLog(`Subcategory selected: ${sub.uzName}`, 'info');
                                }}
                              >
                                <span>{sub.uzName}</span>
                                <ChevronRight size={10} style={{ opacity: 0.5 }} />
                              </button>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  </>
                )}

                {/* 3. POST AD FORM SCREEN */}
                {currentScreen === 'add' && !selectedListingId && (
                  <>
                    <header className="post-ad-header">
                      <h2>Yangi e'lon joylash</h2>
                    </header>
                    <div className="screen-viewport" style={{ background: 'white' }}>
                      <form className="form-body" onSubmit={handlePostAdSubmit}>
                        
                        <div className="form-group">
                          <label className="form-label">E'lon sarlavhasi (Title)</label>
                          <input 
                            type="text" 
                            className="form-input" 
                            placeholder="Sarlavha yozing (masalan: Sotiladi..."
                            value={newAdTitle}
                            onChange={(e) => setNewAdTitle(e.target.value)}
                            required
                          />
                        </div>

                        <div className="form-group">
                          <label className="form-label">Rukn (Category)</label>
                          <select 
                            className="form-select"
                            value={newAdCat}
                            onChange={(e) => setNewAdCat(e.target.value)}
                          >
                            {CATEGORIES.map(c => (
                              <option key={c.id} value={c.id}>{c.uzName}</option>
                            ))}
                          </select>
                        </div>

                        <div className="form-group">
                          <label className="form-label">Nim-rukn (Subcategory)</label>
                          <select 
                            className="form-select"
                            value={newAdSubcat}
                            onChange={(e) => setNewAdSubcat(e.target.value)}
                          >
                            {CATEGORIES.find(c => c.id === newAdCat)?.subcategories?.map(s => (
                              <option key={s.id} value={s.id}>{s.uzName}</option>
                            ))}
                          </select>
                        </div>

                        <div className="form-group">
                          <label className="form-label">Narxi ($ USD)</label>
                          <input 
                            type="number" 
                            className="form-input" 
                            placeholder="Narxi dollar hisobida"
                            value={newAdPrice}
                            onChange={(e) => setNewAdPrice(e.target.value)}
                            required
                          />
                        </div>

                        <div className="form-group">
                          <label className="form-label">Hudud (Location)</label>
                          <select 
                            className="form-select"
                            value={newAdLocation}
                            onChange={(e) => setNewAdLocation(e.target.value)}
                          >
                            <option value="Tashkent City, Tashkent">Toshkent shahar</option>
                            <option value="Samarkand District, Samarkand">Samarqand viloyati</option>
                            <option value="Farg'ona, Fergana">Farg'ona viloyati</option>
                            <option value="Jizzakh Region">Jizzax viloyati</option>
                            <option value="Namangan, Namangan">Namangan viloyati</option>
                            <option value="Gurlan, Khorezm">Xorazm viloyati</option>
                          </select>
                        </div>

                        <div className="form-group">
                          <label className="form-label">Bog'lanish uchun telefon</label>
                          <input 
                            type="text" 
                            className="form-input" 
                            value={newAdPhone}
                            onChange={(e) => setNewAdPhone(e.target.value)}
                            required
                          />
                        </div>

                        <div className="form-group">
                          <label className="form-label">Batafsil ma'lumot (Description)</label>
                          <textarea 
                            className="form-textarea" 
                            placeholder="E'loningiz haqida batafsil ma'lumot yozing..."
                            value={newAdDesc}
                            onChange={(e) => setNewAdDesc(e.target.value)}
                            required
                          ></textarea>
                        </div>

                        <div className="form-group">
                          <label className="form-label">Rasm yuklash (Simulated)</label>
                          <div className="image-upload-selector has-image">
                            <CheckCircle2 size={16} />
                            <span style={{ fontSize: '10px', marginTop: '2px', fontWeight: 600 }}>
                              Rasm avtomatik yuklandi (Vector Illustration)
                            </span>
                          </div>
                        </div>

                        <button type="submit" className="submit-ad-btn">
                          E'lonni faollashtirish
                        </button>
                      </form>
                    </div>
                  </>
                )}

                {/* 4. SAVED / FAVORITES SCREEN */}
                {currentScreen === 'favorites' && !selectedListingId && (
                  <>
                    <header className="post-ad-header">
                      <h2>Saralangan e'lonlar</h2>
                    </header>
                    <div className="screen-viewport">
                      {listings.filter(l => favorites.has(l.id)).length === 0 ? (
                        <div style={{ padding: '60px 20px', textAlign: 'center', color: 'var(--text-muted)' }}>
                          <Heart size={32} style={{ marginBottom: '10px' }} />
                          <p style={{ fontSize: '13px', fontWeight: 'bold' }}>Saralanganlar bo'sh</p>
                          <p style={{ fontSize: '11px' }}>Sizga yoqqan e'lonlarni saqlash tugmasi orqali bu yerda saqlang</p>
                        </div>
                      ) : (
                        <div className="feed-grid" style={{ paddingTop: '16px' }}>
                          {listings.filter(l => favorites.has(l.id)).map(item => (
                            <div 
                              key={item.id} 
                              className="listing-card"
                              onClick={() => {
                                setSelectedListingId(item.id);
                              }}
                            >
                              <div className="card-image-wrapper">
                                <ListingImage type={item.image} />
                                <button 
                                  className="favorite-btn active flex-center"
                                  onClick={(e) => handleToggleFavorite(item.id, e)}
                                >
                                  <Heart size={14} fill="currentColor" />
                                </button>
                              </div>
                              <div className="card-body">
                                <h4 className="card-title">{item.title}</h4>
                                <div className="card-footer">
                                  <span className="card-price">
                                    {item.price.toLocaleString()} {item.currency}
                                  </span>
                                  <button 
                                    className="card-call-btn flex-center"
                                    onClick={(e) => {
                                      e.stopPropagation();
                                      handleStartCall(item);
                                    }}
                                  >
                                    <Phone size={11} fill="currentColor" />
                                  </button>
                                </div>
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  </>
                )}

                {/* 5. USER PROFILE SCREEN */}
                {currentScreen === 'profile' && !selectedListingId && (
                  <>
                    <header className="post-ad-header">
                      <h2>Mening kabinetim</h2>
                    </header>
                    <div className="screen-viewport" style={{ background: '#F8FAFC' }}>
                      <div className="profile-user-card">
                        <div className="profile-avatar flex-center">{currentUser.avatar}</div>
                        <div className="profile-name">{currentUser.name}</div>
                        <span className="profile-role-tag">{currentUser.role}</span>
                        
                        <div className="profile-stats-row">
                          <div className="profile-stat-item">
                            <span className="profile-stat-count">{currentUser.balance}</span>
                            <span className="profile-stat-label">Hamyon balansi</span>
                          </div>
                          <div className="profile-stat-item">
                            <span className="profile-stat-count">
                              {listings.filter(l=>l.sellerName === currentUser.name).length}
                            </span>
                            <span className="profile-stat-label">E'lonlar soni</span>
                          </div>
                        </div>
                      </div>

                      {/* Tab List options */}
                      <div style={{ marginTop: '12px', background: 'white', borderTop: '1px solid var(--border-light)', borderBottom: '1px solid var(--border-light)' }}>
                        <div style={{ padding: '14px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--border-light)' }}>
                          <span style={{ fontSize: '12px', fontWeight: 600 }}>Mening e'lonlarim</span>
                          <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                            {listings.filter(l=>l.sellerName === currentUser.name).length} faol
                          </span>
                        </div>
                        <div style={{ padding: '14px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <span style={{ fontSize: '12px', fontWeight: 600 }}>Sozlamalar</span>
                          <ChevronRight size={14} style={{ color: 'var(--text-muted)' }} />
                        </div>
                      </div>

                      {/* Display user's personal ads */}
                      <div style={{ padding: '16px' }}>
                        <h4 style={{ fontSize: '12px', fontWeight: 700, marginBottom: '8px' }}>Mening faol e'lonlarim</h4>
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                          {listings.filter(l => l.sellerName === currentUser.name).map(item => (
                            <div 
                              key={item.id} 
                              style={{ display: 'flex', background: 'white', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-light)', alignItems: 'center', gap: '10px', cursor: 'pointer' }}
                              onClick={() => setSelectedListingId(item.id)}
                            >
                              <div style={{ width: '40px', height: '40px', borderRadius: '4px', overflow: 'hidden' }}>
                                <ListingImage type={item.image} />
                              </div>
                              <div style={{ flex: 1, minWidth: 0 }}>
                                <div style={{ fontSize: '11px', fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                                  {item.title}
                                </div>
                                <div style={{ fontSize: '10px', fontWeight: 'bold', color: 'var(--primary-soft)', marginTop: '2px' }}>
                                  {item.price.toLocaleString()} {item.currency}
                                </div>
                              </div>
                              <span style={{ fontSize: '9px', background: 'var(--agri-light)', color: 'var(--agri-green)', padding: '2px 6px', borderRadius: '10px', fontWeight: 700 }}>
                                Faol
                              </span>
                            </div>
                          ))}
                          {listings.filter(l => l.sellerName === currentUser.name).length === 0 && (
                            <div style={{ textAlign: 'center', padding: '20px', color: 'var(--text-muted)', fontSize: '11px', background: 'white', borderRadius: '8px' }}>
                              Siz hali e'lon bermadingiz
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  </>
                )}

                {/* =========================================
                   6. DETAILED AD PAGE (Pushed overlay screen)
                   ========================================= */}
                {selectedListingId && selectedListing && (
                  <div className="detail-screen-wrapper animate-slide-up">
                    <header className="detail-nav">
                      <button className="detail-nav-btn flex-center" onClick={() => setSelectedListingId(null)}>
                        <ArrowLeft size={16} />
                      </button>
                      <span style={{ fontSize: '13px', fontWeight: 700, color: 'var(--primary-deep)' }}>E'lon tafsiloti</span>
                      <button className="detail-nav-btn flex-center" onClick={() => {
                        addLog(`Shared listing url for: "${selectedListing.title}"`, 'info');
                        showNotification('Havola ko\'chirildi', 'Ulashish uchun tayyor!');
                      }}>
                        <Share2 size={14} />
                      </button>
                    </header>

                    <div className="detail-scrollable">
                      <div className="detail-image-box">
                        <ListingImage type={selectedListing.image} />
                        <span className={`sector-badge ${
                          selectedListing.category === 'electronics' ? 'tech' : 
                          selectedListing.category === 'real-estate' ? 'real-estate' : 'agriculture'
                        }`} style={{ top: '12px', left: '12px', fontSize: '10px', padding: '3px 8px' }}>
                          {selectedListing.category === 'electronics' ? 'Electronics & Tech' : 
                           selectedListing.category === 'real-estate' ? 'Real Estate' : 'Agriculture & Farming'}
                        </span>
                      </div>

                      <div className="detail-body">
                        <span style={{ fontSize: '10px', textTransform: 'uppercase', fontWeight: 700, color: 'var(--primary-soft)' }}>
                          {CATEGORIES.find(c => c.id === selectedListing.category)?.uzName} &gt; {selectedListing.subcategory}
                        </span>
                        
                        <h1 className="detail-title">{selectedListing.title}</h1>
                        
                        <div className="detail-meta-row">
                          <span className="detail-meta-item">
                            <MapPin size={12} />
                            {selectedListing.location}
                          </span>
                          <span className="detail-meta-item">
                            <Calendar size={12} />
                            {selectedListing.date}
                          </span>
                          <span className="detail-meta-item">
                            <Eye size={12} />
                            {selectedListing.views} marta ko'rildi
                          </span>
                        </div>

                        <div className="detail-price-main" style={{ marginTop: '12px' }}>
                          {selectedListing.price.toLocaleString()} {selectedListing.currency}
                        </div>

                        {/* Seller profile card */}
                        <div className="detail-section-title">Sotuvchi haqida</div>
                        <div className="seller-profile-card">
                          <div className="seller-avatar-info">
                            <div className="seller-avatar-initials flex-center">
                              {selectedListing.sellerName.split(' ').map(n=>n[0]).join('')}
                            </div>
                            <div>
                              <div className="seller-name-title">{selectedListing.sellerName}</div>
                              <div className="seller-type-lbl">
                                {selectedListing.sellerType === 'Company' ? 'Kompaniya vakili' : 'Xususiy sotuvchi'}
                              </div>
                            </div>
                          </div>
                          <span className="seller-badge-verify">Verified Seller</span>
                        </div>

                        {/* Listing description */}
                        <div className="detail-section-title">Tavsif</div>
                        <p className="detail-desc-text">{selectedListing.description}</p>
                      </div>
                    </div>

                    {/* Bottom sticky footer with price and contact phone */}
                    <div className="detail-sticky-footer">
                      <div className="sticky-price-col">
                        <span className="sticky-price-label">Narxi</span>
                        <span className="sticky-price">
                          {selectedListing.price.toLocaleString()} {selectedListing.currency}
                        </span>
                      </div>
                      <button 
                        className="sticky-call-btn"
                        onClick={() => handleStartCall(selectedListing)}
                      >
                        <PhoneCall size={14} />
                        <span>Qo'ng'iroq: {selectedListing.phone.split(' ')[2]}...</span>
                      </button>
                    </div>
                  </div>
                )}

                {/* Dialer call simulation layout overlay */}
                {activeCall && (
                  <div className="phone-call-overlay animate-slide-up">
                    <div className="flex-center" style={{ flexDirection: 'column' }}>
                      <span className="call-ringing-title">
                        {callStatus === 'ringing' ? 'Chiqish qo\'ng\'irog\'i...' : 'Aloqada'}
                      </span>
                      <h2 className="call-contact-name">{activeCall.sellerName}</h2>
                      <div className="call-number-detail">{activeCall.phone}</div>
                      <span style={{ fontSize: '10px', opacity: 0.6, marginTop: '8px' }}>
                        Mavzu: {activeCall.title.substring(0, 30)}...
                      </span>
                    </div>

                    {/* Circular ringing graphic */}
                    <div className="call-pulse-animation">
                      <div className="call-pulse-inner flex-center">
                        <PhoneCall size={28} />
                      </div>
                    </div>

                    <div className="call-controls-box">
                      <span className="call-status-msg">
                        {callStatus === 'ringing' ? 'Simulyatsiya qilinmoqda...' : `Gaplashilmoqda: ${Math.floor(callTimer / 60)}:${(callTimer % 60).toString().padStart(2, '0')}`}
                      </span>
                      <button 
                        className="end-call-btn flex-center"
                        onClick={handleEndCall}
                      >
                        <X size={24} />
                      </button>
                    </div>
                  </div>
                )}

                {/* BOTTOM HANDSET NAVIGATION BAR */}
                <nav className="app-tab-bar">
                  <button 
                    className={`tab-btn ${currentScreen === 'home' ? 'active' : ''}`}
                    onClick={() => {
                      setCurrentScreen('home');
                      setSelectedListingId(null);
                      addLog('Navigated to Home Feed', 'info');
                    }}
                  >
                    <Home />
                    <span>Asosiy</span>
                  </button>

                  <button 
                    className={`tab-btn ${currentScreen === 'categories' ? 'active' : ''}`}
                    onClick={() => {
                      setCurrentScreen('categories');
                      setSelectedListingId(null);
                      addLog('Navigated to Category Browser', 'info');
                    }}
                  >
                    <Search />
                    <span>Bo'limlar</span>
                  </button>

                  <button 
                    className={`tab-btn ${currentScreen === 'add' ? 'active' : ''}`}
                    onClick={() => {
                      setCurrentScreen('add');
                      setSelectedListingId(null);
                      addLog('Navigated to Add Post Form', 'info');
                    }}
                  >
                    <PlusCircle style={{ width: '24px', height: '24px', color: 'var(--primary-soft)' }} />
                    <span style={{ color: 'var(--primary-deep)', fontWeight: 'bold' }}>E'lon berish</span>
                  </button>

                  <button 
                    className={`tab-btn ${currentScreen === 'favorites' ? 'active' : ''}`}
                    onClick={() => {
                      setCurrentScreen('favorites');
                      setSelectedListingId(null);
                      addLog('Navigated to Saved Listings', 'info');
                    }}
                  >
                    <Heart />
                    <span>Saralanganlar</span>
                    {favorites.size > 0 && <span className="tab-badge">{favorites.size}</span>}
                  </button>

                  <button 
                    className={`tab-btn ${currentScreen === 'profile' ? 'active' : ''}`}
                    onClick={() => {
                      setCurrentScreen('profile');
                      setSelectedListingId(null);
                      addLog('Navigated to Profile screen', 'info');
                    }}
                  >
                    <User />
                    <span>Kabinet</span>
                  </button>
                </nav>

                {/* Home Indicator line (casing accent) */}
                <div className="home-indicator-bar"></div>

              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
