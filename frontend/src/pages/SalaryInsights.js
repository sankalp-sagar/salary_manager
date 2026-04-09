import React, { useState, useEffect } from 'react';
import {
  BarChart, Bar, LineChart, Line, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer
} from 'recharts';
import api from '../services/api';
import './SalaryInsights.css';

function SalaryInsights() {
  const [countryData, setCountryData] = useState([]);
  const [employmentData, setEmploymentData] = useState([]);
  const [topJobTitles, setTopJobTitles] = useState([]);
  const [jobTitleData, setJobTitleData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedCountry, setSelectedCountry] = useState('');
  const [selectedJobTitle, setSelectedJobTitle] = useState('');

  const COLORS = ['#3498db', '#2ecc71', '#e74c3c', '#f39c12', '#9b59b6', '#1abc9c', '#34495e', '#e67e22'];

  useEffect(() => {
    fetchAllInsights();
  }, []);

  const fetchAllInsights = async () => {
    try {
      setLoading(true);
      const [countryRes, employmentRes, topJobsRes] = await Promise.all([
        api.getSalaryInsightsByCountry(),
        api.getEmploymentByCountry(),
        api.getTopJobTitles()
      ]);

      setCountryData(countryRes.data);
      setEmploymentData(employmentRes.data);
      setTopJobTitles(topJobsRes.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch salary insights');
      console.error('Error fetching insights:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchJobTitleInsights = async (country, jobTitle = '') => {
    try {
      const response = await api.getSalaryInsightsByJobTitleInCountry(country, jobTitle);
      setJobTitleData(response.data);
    } catch (err) {
      console.error('Error fetching job title insights:', err);
    }
  };

  const handleCountryChange = (country) => {
    setSelectedCountry(country);
    if (country) {
      fetchJobTitleInsights(country);
    } else {
      setJobTitleData([]);
    }
    setSelectedJobTitle('');
  };

  const handleJobTitleChange = (jobTitle) => {
    setSelectedJobTitle(jobTitle);
    if (selectedCountry) {
      fetchJobTitleInsights(selectedCountry, jobTitle);
    }
  };

  const uniqueCountries = [...new Set(countryData.map(item => item.country))];
  const uniqueJobTitles = [...new Set(jobTitleData.map(item => item.job_title))];

  const totalEmployees = countryData.reduce((sum, item) => sum + item.employee_count, 0);
  const avgSalary = countryData.length > 0
    ? (countryData.reduce((sum, item) => sum + (item.avg_salary || 0), 0) / countryData.length).toFixed(2)
    : 0;

  if (loading) return <div className="loading">📊 Loading salary insights...</div>;
  if (error) return <div className="error">❌ {error}</div>;

  return (
    <div className="salary-insights">
      <h1>💼 Salary Insights Dashboard</h1>

      {/* KPI Cards */}
      <div className="kpi-grid">
        <div className="kpi-card">
          <div className="kpi-value">{totalEmployees.toLocaleString()}</div>
          <div className="kpi-label">Total Employees</div>
        </div>
        <div className="kpi-card">
          <div className="kpi-value">{countryData.length}</div>
          <div className="kpi-label">Countries</div>
        </div>
        <div className="kpi-card">
          <div className="kpi-value">${(avgSalary / 1000).toFixed(1)}K</div>
          <div className="kpi-label">Avg Salary</div>
        </div>
        <div className="kpi-card">
          <div className="kpi-value">${countryData.reduce((max, item) => Math.max(max, item.max_salary || 0), 0).toLocaleString()}</div>
          <div className="kpi-label">Max Salary</div>
        </div>
      </div>

      <div className="insights-grid">
        {/* Salary by Country - Bar Chart */}
        <div className="insight-card full-width">
          <h2>📊 Salary Statistics by Country</h2>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={countryData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#ecf0f1" />
              <XAxis dataKey="country" />
              <YAxis />
              <Tooltip
                formatter={(value) => `$${value.toLocaleString()}`}
                contentStyle={{ backgroundColor: '#2c3e50', border: 'none', borderRadius: '8px', color: '#fff' }}
              />
              <Legend />
              <Bar dataKey="min_salary" fill="#3498db" name="Min Salary" radius={[8, 8, 0, 0]} />
              <Bar dataKey="max_salary" fill="#e74c3c" name="Max Salary" radius={[8, 8, 0, 0]} />
              <Bar dataKey="avg_salary" fill="#2ecc71" name="Avg Salary" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Employment Status by Country */}
        <div className="insight-card">
          <h2>👥 Employment Status</h2>
          <ResponsiveContainer width="100%" height={350}>
            <BarChart data={employmentData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#ecf0f1" />
              <XAxis dataKey="country" angle={-45} textAnchor="end" height={100} />
              <YAxis />
              <Tooltip
                contentStyle={{ backgroundColor: '#2c3e50', border: 'none', borderRadius: '8px', color: '#fff' }}
              />
              <Legend />
              <Bar dataKey="active_count" fill="#2ecc71" name="Active" radius={[8, 8, 0, 0]} />
              <Bar dataKey="former_count" fill="#e74c3c" name="Former" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Top Job Titles - Pie Chart */}
        <div className="insight-card">
          <h2>🏆 Top Job Titles</h2>
          <ResponsiveContainer width="100%" height={350}>
            <PieChart>
              <Pie
                data={topJobTitles}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="employee_count"
              >
                {topJobTitles.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => value.toLocaleString()} />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Average Salary Trend */}
        <div className="insight-card">
          <h2>📈 Salary Range by Country</h2>
          <ResponsiveContainer width="100%" height={350}>
            <LineChart data={countryData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#ecf0f1" />
              <XAxis dataKey="country" angle={-45} textAnchor="end" height={100} />
              <YAxis />
              <Tooltip
                formatter={(value) => `$${value.toLocaleString()}`}
                contentStyle={{ backgroundColor: '#2c3e50', border: 'none', borderRadius: '8px', color: '#fff' }}
              />
              <Legend />
              <Line type="monotone" dataKey="min_salary" stroke="#3498db" name="Min Salary" strokeWidth={2} />
              <Line type="monotone" dataKey="avg_salary" stroke="#2ecc71" name="Avg Salary" strokeWidth={2} />
              <Line type="monotone" dataKey="max_salary" stroke="#e74c3c" name="Max Salary" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Job Title Insights */}
        <div className="insight-card full-width">
          <h2>💼 Salary by Job Title in Country</h2>
          <div className="filters">
            <select
              value={selectedCountry}
              onChange={(e) => handleCountryChange(e.target.value)}
              className="filter-select"
            >
              <option value="">Select Country</option>
              {uniqueCountries.map(country => (
                <option key={country} value={country}>{country}</option>
              ))}
            </select>

            {selectedCountry && (
              <select
                value={selectedJobTitle}
                onChange={(e) => handleJobTitleChange(e.target.value)}
                className="filter-select"
              >
                <option value="">All Job Titles</option>
                {uniqueJobTitles.map(jobTitle => (
                  <option key={jobTitle} value={jobTitle}>{jobTitle}</option>
                ))}
              </select>
            )}
          </div>

          {jobTitleData.length > 0 && (
            <ResponsiveContainer width="100%" height={400}>
              <BarChart data={jobTitleData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#ecf0f1" />
                <XAxis dataKey="job_title" angle={-45} textAnchor="end" height={100} />
                <YAxis yAxisId="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip
                  formatter={(value) => typeof value === 'number' ? `$${value.toLocaleString()}` : value}
                  contentStyle={{ backgroundColor: '#2c3e50', border: 'none', borderRadius: '8px', color: '#fff' }}
                />
                <Legend />
                <Bar yAxisId="right" dataKey="employee_count" fill="#3498db" name="Employee Count" radius={[8, 8, 0, 0]} />
                <Bar yAxisId="left" dataKey="avg_salary" fill="#2ecc71" name="Avg Salary" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>
    </div>
  );
}

export default SalaryInsights;