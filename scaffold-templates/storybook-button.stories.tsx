import React from 'react';
import { Button } from '@/stories/Button';

export default {
  title: 'Components/Button',
  component: Button,
};

export const Primary = () => (
  <Button label="Primary Button" primary={true} />
);
