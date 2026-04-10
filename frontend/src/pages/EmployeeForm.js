import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import api from '../services/api';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/card';

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
    <div className="container mx-auto py-8">
      <Card className="max-w-2xl mx-auto">
        <CardHeader>
          <CardTitle>{isEditing ? 'Edit Employee' : 'Add New Employee'}</CardTitle>
        </CardHeader>
        <CardContent>
          {error && <div className="text-destructive mb-4">{error}</div>}
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="first_name" className="block text-sm font-medium mb-1">First Name *</label>
                <Input
                  type="text"
                  id="first_name"
                  name="first_name"
                  value={formData.first_name}
                  onChange={handleChange}
                  required
                />
              </div>
              <div>
                <label htmlFor="last_name" className="block text-sm font-medium mb-1">Last Name *</label>
                <Input
                  type="text"
                  id="last_name"
                  name="last_name"
                  value={formData.last_name}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="job_title" className="block text-sm font-medium mb-1">Job Title *</label>
                <Input
                  type="text"
                  id="job_title"
                  name="job_title"
                  value={formData.job_title}
                  onChange={handleChange}
                  required
                />
              </div>
              <div>
                <label htmlFor="country" className="block text-sm font-medium mb-1">Country *</label>
                <Input
                  type="text"
                  id="country"
                  name="country"
                  value={formData.country}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="salary" className="block text-sm font-medium mb-1">Salary *</label>
                <Input
                  type="number"
                  id="salary"
                  name="salary"
                  value={formData.salary}
                  onChange={handleChange}
                  min="0"
                  required
                />
              </div>
              <div>
                <label htmlFor="joining_date" className="block text-sm font-medium mb-1">Joining Date *</label>
                <Input
                  type="date"
                  id="joining_date"
                  name="joining_date"
                  value={formData.joining_date}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            <div>
              <label htmlFor="left_at" className="block text-sm font-medium mb-1">Left At (leave empty if still employed)</label>
              <Input
                type="date"
                id="left_at"
                name="left_at"
                value={formData.left_at}
                onChange={handleChange}
              />
            </div>
            <div className="flex gap-4">
              <Button type="submit" disabled={loading}>
                {loading ? 'Saving...' : (isEditing ? 'Update Employee' : 'Create Employee')}
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => navigate('/employees')}
              >
                Cancel
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

export default EmployeeForm;