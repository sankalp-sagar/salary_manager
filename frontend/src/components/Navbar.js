import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import './Navbar.css';

function Navbar() {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('authToken');
    navigate('/login');
  };

  const isLoggedIn = localStorage.getItem('authToken');

  return (
    <nav className="navbar">
      <div className="navbar-brand">
        <Link to="/">Salary Manager</Link>
      </div>
      <div className="navbar-menu">
        {isLoggedIn ? (
          <>
            <Link to="/employees" className="navbar-item">Employees</Link>
            <Link to="/insights" className="navbar-item">Salary Insights</Link>
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