import React from 'react';
import {
  ShoppingBag,
  Plane,
  Car,
  Home,
  ShieldCheck,
  BookOpen,
  Megaphone,
  Wifi,
  Droplets,
  Key,
  Dumbbell,
  Bell,
  Palmtree,
  Utensils,
  Grid,
  Plus,
  Coffee,
  HeartPulse,
  Tv,
  HelpCircle,
  Tag
} from 'lucide-react';

interface CategoryIconProps {
  iconName: string;
  color?: string;
  className?: string;
  size?: number;
}

export const CategoryIcon: React.FC<CategoryIconProps> = ({
  iconName,
  color,
  className = '',
  size = 20,
}) => {
  const props = {
    size,
    color,
    className,
  };

  switch (iconName.toLowerCase()) {
    case 'shoppingbag':
    case 'shopping':
    case 'groceries':
      return <ShoppingBag {...props} />;
    case 'plane':
    case 'travel':
      return <Plane {...props} />;
    case 'car':
      return <Car {...props} />;
    case 'home':
      return <Home {...props} />;
    case 'shieldcheck':
    case 'insurance':
    case 'shield':
      return <ShieldCheck {...props} />;
    case 'bookopen':
    case 'education':
    case 'book':
      return <BookOpen {...props} />;
    case 'megaphone':
    case 'marketing':
      return <Megaphone {...props} />;
    case 'wifi':
    case 'internet':
      return <Wifi {...props} />;
    case 'droplets':
    case 'water':
      return <Droplets {...props} />;
    case 'key':
    case 'rent':
      return <Key {...props} />;
    case 'dumbbell':
    case 'gym':
      return <Dumbbell {...props} />;
    case 'bell':
    case 'subscription':
      return <Bell {...props} />;
    case 'palmtree':
    case 'vacation':
      return <Palmtree {...props} />;
    case 'utensils':
    case 'dining':
    case 'food':
      return <Utensils {...props} />;
    case 'coffee':
      return <Coffee {...props} />;
    case 'heartpulse':
    case 'health':
      return <HeartPulse {...props} />;
    case 'tv':
    case 'entertainment':
      return <Tv {...props} />;
    case 'plus':
      return <Plus {...props} />;
    case 'tag':
      return <Tag {...props} />;
    case 'grid':
    case 'other':
    default:
      return <Grid {...props} />;
  }
};
