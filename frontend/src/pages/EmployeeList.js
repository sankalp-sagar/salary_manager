import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import api from '../services/api';
import './EmployeeList.css';

function EmployeeList() {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    fetchEmployees();
  }, [currentPage]);

  const fetchEmployees = async () => {
    try {
      setLoading(true);
      const response = await api.getEmployees(currentPage);
      setEmployees(response.data);
      setTotalPages(Math.ceil(response.meta.total / response.meta.per_page));
      setError(null);
    } catch (err) {
      setError('Failed to fetch employees');
      console.error('Error fetching employees:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this employee?')) {
      try {
        await api.deleteEmployee(id);
        fetchEmployees(); // Refresh the list
      } catch (err) {
        setError('Failed to delete employee');
        console.error('Error deleting employee:', err);
      }
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString();
  };

  if (loading) return <div className="loading">Loading employees...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="employee-list">
      <div className="header">
        <h1>Employees</h1>
        <Link to="/employees/new" className="btn btn-primary">
          Add New Employee
        </Link>
      </div>

      <div className="table-container">
        <table className="employee-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Job Title</th>
              <th>Country</th>
              <th>Salary</th>
              <th>Joining Date</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {employees.map((employee) => (
              <tr key={employee.id}>
                <td>{`${employee.first_name} ${employee.last_name}`}</td>
                <td>{employee.job_title}</td>
                <td>{employee.country}</td>
                <td>${employee.salary?.toLocaleString()}</td>
                <td>{formatDate(employee.joining_date)}</td>
                <td>
                  <span className={`status ${employee.left_at ? 'former' : 'active'}`}>
                    {employee.left_at ? 'Former' : 'Active'}
                  </span>
                </td>
                <td>
                  <div className="actions">
                    <Link to={`/employees/${employee.id}/edit`} className="btn btn-secondary btn-sm">
                      Edit
                    </Link>
                    <button
                      onClick={() => handleDelete(employee.id)}
                      className="btn btn-danger btn-sm"
                    >
                      Delete
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="pagination">
        <button
          onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
          disabled={currentPage === 1}
          className="btn btn-secondary"
        >
          Previous
        </button>
        <span>Page {currentPage} of {totalPages}</span>
        <button
          onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
          disabled={currentPage === totalPages}
          className="btn btn-secondary"
        >
          Next
        </button>
      </div>
    </div>
  );
}

export default EmployeeList;