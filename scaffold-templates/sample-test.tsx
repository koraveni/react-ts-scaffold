import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom'
import App from './App';

test('renders learn react link', () => {
  render(<App />);
  const linkElement = screen.getByText(/Vite \+ React/i);
  expect(linkElement).toBeInTheDocument();
});
