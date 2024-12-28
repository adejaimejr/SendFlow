import React from "react";
import { Card } from "@/components/ui/card";
import { ArrowUpIcon, ArrowDownIcon } from "lucide-react";

interface MetricCardProps {
  icon?: React.ReactNode;
  label?: string;
  value?: string | number;
  trend?: number;
  trendLabel?: string;
}

const MetricCard = ({
  icon = <div className="w-8 h-8 bg-slate-600 rounded-full" />,
  label = "Metric",
  value = "0",
  trend = 0,
  trendLabel = "vs last period",
}: MetricCardProps) => {
  const isTrendPositive = trend >= 0;

  return (
    <Card className="p-6 bg-slate-800 text-white hover:bg-slate-700 transition-colors">
      <div className="flex flex-col h-full justify-between gap-4">
        <div className="flex items-center justify-between">
          <div className="p-2 bg-slate-700 rounded-lg">{icon}</div>
          <div className="flex items-center gap-2">
            <span
              className={`flex items-center text-sm ${isTrendPositive ? "text-green-400" : "text-red-400"}`}
            >
              {isTrendPositive ? (
                <ArrowUpIcon className="w-4 h-4" />
              ) : (
                <ArrowDownIcon className="w-4 h-4" />
              )}
              {Math.abs(trend)}%
            </span>
          </div>
        </div>

        <div>
          <div className="text-3xl font-bold mb-1">{value}</div>
          <div className="text-slate-400 text-sm flex justify-between">
            <span>{label}</span>
            <span className="text-slate-500">{trendLabel}</span>
          </div>
        </div>
      </div>
    </Card>
  );
};

export default MetricCard;
