import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import HomePage from './pages/HomePage';
import SearchPage from './pages/SearchPage';
import ListingDetailPage from './pages/ListingDetailPage';
import CategoriesPage from './pages/CategoriesPage';
import SavedPage from './pages/SavedPage';
import MessagesPage from './pages/MessagesPage';
import MessageDetailPage from './pages/MessageDetailPage';
import ProfilePage from './pages/ProfilePage';
import NewListingPage from './pages/NewListingPage';

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/search" element={<SearchPage />} />
        <Route path="/listing/:id" element={<ListingDetailPage />} />
        <Route path="/categories" element={<CategoriesPage />} />
        <Route path="/saved" element={<SavedPage />} />
        <Route path="/messages" element={<MessagesPage />} />
        <Route path="/messages/:id" element={<MessageDetailPage />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/new-listing" element={<NewListingPage />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
