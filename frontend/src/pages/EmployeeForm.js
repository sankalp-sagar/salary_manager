import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import api from '../services/api';
import './EmployeeForm.css';

function EmployeeForm() {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEditing = !!id;

  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    job_title: '',
    country: '',
    salary: '',
    joining_date: '',
    left_at: ''
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (isEditing) {
      fetchEmployee();
    }
  }, [id]);

  const fetchEmployee = async () => {
    try {
      const employee = await api.getEmployee(id);
      setFormData({
        first_name: employee.first_name || '',
        last_name: employee.last_name || '',
        job_title: employee.job_title || '',
        country: employee.country || '',
        salary: employee.salary || '',
        joining_date: employee.joining_date ? employee.joining_date.split('T')[0] : '',
        left_at: employee.left_at ? employee.left_at.split('T')[0] : ''
      });
    } catch (err) {
      setError('Failed to fetch employee');
      console.error('Error fetching employee:', err);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const submitData = {
        ...formData,
        salary: parseInt(formData.salary) || 0
      };

      if (isEditing) {
        await api.updateEmployee(id, submitData);
      } else {
        await api.createEmployee(submitData);
      }

      navigate('/employees');
    } catch (err) {
      setError(isEditing ? 'Failed to update employee' : 'Failed to create employee');
      console.error('Error saving employee:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="employee-form">
      <div className="form-header">
        <h1>{isEditing ? 'Edit Employee' : 'Add New Employee'}</h1>
      </div>

      {error && <div className="error">{error}</div>}

      <form onSubmit={handleSubmit} className="form">
        <div className="form-row">
          <div className="form-group">
            <label htmlFor="first_name">First Name *</label>
            <input
              type="text"
              id="first_name"
              name="first_name"
              value={formData.first_name}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="last_name">Last Name *</label>
            <input
              type="text"
              id="last_name"
              name="last_name"
              value={formData.last_name}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <div className="form-row">
          <div className="form-group">
            <label htmlFor="job_title">Job Title *</label>
            <input
              type="text"
              id="job_title"
              name="job_title"
              value={formData.job_title}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="country">Country *</label>
            <input
              type="text"
              id="country"
              name="country"
              value={formData.country}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <div className="form-row">
          <div className="form-group">
            <label htmlFor="salary">Salary *</label>
            <input
              type="number"
              id="salary"
              name="salary"
              value={formData.salary}
              onChange={handleChange}
              min="0"
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="joining_date">Joining Date *</label>
            <input
              type="date"
              id="joining_date"
              name="joining_date"
              value={formData.joining_date}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <div className="form-group">
          <label htmlFor="left_at">Left At (leave empty if still employed)</label>
          <input
            type="date"
            id="left_at"
            name="left_at"
            value={formData.left_at}
            onChange={handleChange}
          />
        </div>

        <div className="form-actions">
          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? 'Saving...' : (isEditing ? 'Update Employee' : 'Create Employee')}
          </button>
          <button
            type="button"
            onClick={() => navigate('/employees')}
            className="btn btn-secondary"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}

export default EmployeeForm;