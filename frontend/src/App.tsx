import { useState } from 'react';
import HealthDashboard from './components/HealthDashboard';
import './App.css';

function App() {
  const [darkMode, setDarkMode] = useState(false);

  const toggleDarkMode = () => {
    setDarkMode(!darkMode);
    document.documentElement.classList.toggle('dark');
  };

  return (
    <div className={darkMode ? 'dark' : ''}>
      {/* Theme Toggle Button */}
      <button
        onClick={toggleDarkMode}
        className="fixed top-4 right-4 z-50 bg-white dark:bg-gray-800 border-2 border-gray-300 dark:border-gray-600 rounded-full p-3 shadow-lg hover:shadow-xl transition-all duration-300"
        aria-label="Toggle dark mode"
      >
        <span className="text-2xl">
          {darkMode ? '☀️' : '🌙'}
        </span>
      </button>

      {/* Main Dashboard */}
      <HealthDashboard />
    </div>
  );
}

export default App;
