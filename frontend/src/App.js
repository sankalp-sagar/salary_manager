import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';
import Navbar from './components/Navbar';
import ProtectedRoute from './components/ProtectedRoute';
import EmployeeList from './pages/EmployeeList';
import EmployeeForm from './pages/EmployeeForm';
import SalaryInsights from './pages/SalaryInsights';
import Login from './pages/Login';
import api from './services/api';

function App() {
  useEffect(() => {
    const pingInterval = setInterval(async () => {
      try {
        fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:3001'}/up`)
      } catch (error) {
        console.log('Keep-alive ping failed (expected if backend down):', error);
      }
    }, 10000); 

    return () => clearInterval(pingInterval);
  }, []);

  return (
    <Router>
      <div className="App">
        <Navbar />
        <main className="main-content">
          <Routes>
            <Route
              path="/"
              element={
                <ProtectedRoute>
                  <EmployeeList />
                </ProtectedRoute>
              }
            />
            <Route
              path="/employees"
              element={
                <ProtectedRoute>
                  <EmployeeList />
                </ProtectedRoute>
              }
            />
            <Route
              path="/employees/new"
              element={
                <ProtectedRoute>
                  <EmployeeForm />
                </ProtectedRoute>
              }
            />
            <Route
              path="/employees/:id/edit"
              element={
                <ProtectedRoute>
                  <EmployeeForm />
                </ProtectedRoute>
              }
            />
            <Route
              path="/insights"
              element={
                <ProtectedRoute>
                  <SalaryInsights />
                </ProtectedRoute>
              }
            />
            <Route path="/login" element={<Login />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;