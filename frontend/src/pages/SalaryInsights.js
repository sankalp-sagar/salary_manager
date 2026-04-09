import React, { useState, useEffect } from 'react';
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

  if (loading) return <div className="loading">Loading salary insights...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="salary-insights">
      <h1>Salary Insights</h1>

      <div className="insights-grid">
        {/* Salary by Country */}
        <div className="insight-card">
          <h2>Salary Statistics by Country</h2>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Country</th>
                  <th>Employees</th>
                  <th>Min Salary</th>
                  <th>Max Salary</th>
                  <th>Avg Salary</th>
                </tr>
              </thead>
              <tbody>
                {countryData.map((item) => (
                  <tr key={item.country}>
                    <td>{item.country}</td>
                    <td>{item.employee_count}</td>
                    <td>${item.min_salary?.toLocaleString()}</td>
                    <td>${item.max_salary?.toLocaleString()}</td>
                    <td>${item.avg_salary?.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Employment by Country */}
        <div className="insight-card">
          <h2>Employment Status by Country</h2>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Country</th>
                  <th>Active</th>
                  <th>Former</th>
                  <th>Active Avg Salary</th>
                  <th>Former Avg Salary</th>
                </tr>
              </thead>
              <tbody>
                {employmentData.map((item) => (
                  <tr key={item.country}>
                    <td>{item.country}</td>
                    <td>{item.active_count}</td>
                    <td>{item.former_count}</td>
                    <td>${item.active_avg_salary?.toFixed(2)}</td>
                    <td>${item.former_avg_salary?.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Job Title Insights */}
        <div className="insight-card">
          <h2>Salary by Job Title in Country</h2>
          <div className="filters">
            <select
              value={selectedCountry}
              onChange={(e) => handleCountryChange(e.target.value)}
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
              >
                <option value="">All Job Titles</option>
                {uniqueJobTitles.map(jobTitle => (
                  <option key={jobTitle} value={jobTitle}>{jobTitle}</option>
                ))}
              </select>
            )}
          </div>

          {jobTitleData.length > 0 && (
            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>Job Title</th>
                    <th>Employees</th>
                    <th>Min Salary</th>
                    <th>Max Salary</th>
                    <th>Avg Salary</th>
                  </tr>
                </thead>
                <tbody>
                  {jobTitleData.map((item, index) => (
                    <tr key={`${item.job_title}-${index}`}>
                      <td>{item.job_title}</td>
                      <td>{item.employee_count}</td>
                      <td>${item.min_salary?.toLocaleString()}</td>
                      <td>${item.max_salary?.toLocaleString()}</td>
                      <td>${item.avg_salary?.toFixed(2)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Top Job Titles */}
        <div className="insight-card">
          <h2>Top Job Titles</h2>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Job Title</th>
                  <th>Employee Count</th>
                </tr>
              </thead>
              <tbody>
                {topJobTitles.map((item) => (
                  <tr key={item.job_title}>
                    <td>{item.job_title}</td>
                    <td>{item.employee_count}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}

export default SalaryInsights;