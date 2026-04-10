import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import api from '../services/api';
import { Button } from '../components/ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../components/ui/table';

function EmployeeList() {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalEmployees, setTotalEmployees] = useState(0);

  useEffect(() => {
    fetchEmployees();
  }, [currentPage]);

  const fetchEmployees = async () => {
    try {
      setLoading(true);
      const response = await api.getEmployees(currentPage);
      setEmployees(response.data);
      setTotalEmployees(response.meta.total || 0);
      setTotalPages(Math.ceil((response.meta.total || 0) / response.meta.per_page));
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

  if (loading) return <div className="flex min-h-[70vh] items-center justify-center">Loading employees...</div>;
  if (error) return <div className="text-destructive text-center py-8">{error}</div>;

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
      <div className="mb-6 flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight text-slate-900">Employee Directory</h1>
          <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-600">
            Manage employee records, update salaries, and track status in one clean dashboard.
          </p>
        </div>
        <Link to="/employees/new">
          <Button>Add New Employee</Button>
        </Link>
      </div>

      <div className="grid gap-4 lg:grid-cols-3 mb-6">
        <Card className="border border-slate-200 bg-white shadow-sm">
          <CardContent className="space-y-1">
            <p className="text-sm text-slate-500">Total employees</p>
            <p className="text-2xl font-semibold text-slate-900">{totalEmployees.toLocaleString()}</p>
          </CardContent>
        </Card>
        <Card className="border border-slate-200 bg-white shadow-sm">
          <CardContent className="space-y-1">
            <p className="text-sm text-slate-500">Current page</p>
            <p className="text-2xl font-semibold text-slate-900">{currentPage} / {totalPages}</p>
          </CardContent>
        </Card>
        <Card className="border border-slate-200 bg-white shadow-sm">
          <CardContent className="space-y-1">
            <p className="text-sm text-slate-500">Shown records</p>
            <p className="text-2xl font-semibold text-slate-900">{employees.length}</p>
          </CardContent>
        </Card>
      </div>

      <Card className="overflow-hidden shadow-sm">
        <CardHeader className="bg-slate-50 px-6 py-4">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <CardTitle className="text-lg font-semibold">Employees</CardTitle>
            <span className="inline-flex items-center rounded-full bg-slate-100 px-3 py-1 text-sm font-medium text-slate-700">
              Active view
            </span>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Table className="w-full min-w-[760px] border-separate border-spacing-y-2">
            <TableHeader>
              <TableRow className="bg-slate-100">
                <TableHead>Name</TableHead>
                <TableHead>Job Title</TableHead>
                <TableHead>Country</TableHead>
                <TableHead>Salary</TableHead>
                <TableHead>Joined</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {employees.map((employee) => (
                <TableRow key={employee.id} className="bg-white transition hover:bg-slate-50">
                  <TableCell className="font-medium text-slate-900">
                    {`${employee.first_name} ${employee.last_name}`}
                  </TableCell>
                  <TableCell className="text-slate-700">{employee.job_title}</TableCell>
                  <TableCell className="text-slate-700">{employee.country}</TableCell>
                  <TableCell className="text-slate-700">${employee.salary?.toLocaleString()}</TableCell>
                  <TableCell className="text-slate-700">{formatDate(employee.joining_date)}</TableCell>
                  <TableCell>
                    <span className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold ${
                      employee.left_at ? 'bg-red-100 text-red-800' : 'bg-emerald-100 text-emerald-800'
                    }`}>
                      {employee.left_at ? 'Former' : 'Active'}
                    </span>
                  </TableCell>
                  <TableCell>
                    <div className="flex flex-wrap gap-2">
                      <Link to={`/employees/${employee.id}/edit`}>
                        <Button variant="outline" size="sm">Edit</Button>
                      </Link>
                      <Button
                        variant="destructive"
                        size="sm"
                        onClick={() => handleDelete(employee.id)}
                      >
                        Delete
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <div className="mt-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <p className="text-sm text-slate-600">Showing {employees.length} employees on this page.</p>
        <div className="flex items-center gap-3">
          <Button
            variant="outline"
            onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
          >
            Previous
          </Button>
          <span className="text-sm text-slate-700">Page {currentPage} of {totalPages}</span>
          <Button
            variant="outline"
            onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))}
            disabled={currentPage === totalPages}
          >
            Next
          </Button>
        </div>
      </div>
    </div>
  );
}

export default EmployeeList;
