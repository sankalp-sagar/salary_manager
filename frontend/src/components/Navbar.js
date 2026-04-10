import React from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import './Navbar.css';

function Navbar() {
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    localStorage.removeItem('authToken');
    navigate('/login');
  };

  const isLoggedIn = localStorage.getItem('authToken');

  const isActive = (path) => {
    if (path === '/employees') {
      return location.pathname.startsWith('/employees');
    }
    return location.pathname === path;
  };

  return (
    <nav className="navbar">
      <div className="navbar-brand">
        <Link to="/">Salary Manager</Link>
      </div>
      <div className="navbar-menu">
        {isLoggedIn ? (
          <>
            <Link to="/employees" className={`navbar-item ${isActive('/employees') ? 'active' : ''}`}>
              Employees
            </Link>
            <Link to="/insights" className={`navbar-item ${isActive('/insights') ? 'active' : ''}`}>
              Salary Insights
            </Link>
            <button onClick={handleLogout} className="navbar-item logout-btn">
              Logout
            </button>
          </>
        ) : (
          <Link to="/login" className="navbar-item">Login</Link>
        )}
      </div>
    </nav>
  );
}

export default Navbar;