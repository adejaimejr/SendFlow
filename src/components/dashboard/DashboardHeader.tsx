import React from "react";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Card } from "@/components/ui/card";

interface DashboardHeaderProps {
  selectedPeriod?: string;
  onPeriodChange?: (value: string) => void;
}

const DashboardHeader = ({
  selectedPeriod = "7d",
  onPeriodChange = () => {},
}: DashboardHeaderProps) => {
  return (
    <Card className="sticky top-0 z-50 w-full px-6 py-4 bg-slate-800 border-b border-slate-700">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-white">Campaign Dashboard</h1>

        <div className="flex items-center gap-4">
          <Select value={selectedPeriod} onValueChange={onPeriodChange}>
            <SelectTrigger className="w-[180px] bg-slate-700 text-white border-slate-600">
              <SelectValue placeholder="Select period" />
            </SelectTrigger>
            <SelectContent className="bg-slate-700 text-white border-slate-600">
              <SelectItem value="24h">Last 24 Hours</SelectItem>
              <SelectItem value="7d">Last 7 Days</SelectItem>
              <SelectItem value="30d">Last 30 Days</SelectItem>
              <SelectItem value="90d">Last 90 Days</SelectItem>
              <SelectItem value="custom">Custom Range</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>
    </Card>
  );
};

export default DashboardHeader;
