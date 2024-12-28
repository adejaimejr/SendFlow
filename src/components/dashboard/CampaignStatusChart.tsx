import React from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Legend,
  Tooltip,
} from "recharts";

interface CampaignStatusChartProps {
  data?: Array<{
    name: string;
    value: number;
    color: string;
  }>;
}

const defaultData = [
  { name: "Active", value: 35, color: "#22c55e" },
  { name: "Completed", value: 45, color: "#3b82f6" },
  { name: "Failed", value: 10, color: "#ef4444" },
  { name: "Pending", value: 10, color: "#f59e0b" },
];

const CampaignStatusChart = ({
  data = defaultData,
}: CampaignStatusChartProps) => {
  return (
    <Card className="w-full h-[400px] bg-slate-800">
      <CardHeader>
        <CardTitle className="text-lg font-semibold text-slate-100">
          Campaign Status Distribution
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="w-full h-[300px]">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={data}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={80}
                paddingAngle={5}
                dataKey="value"
              >
                {data.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip />
              <Legend
                verticalAlign="bottom"
                height={36}
                formatter={(value) => (
                  <span className="text-slate-100">{value}</span>
                )}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
};

export default CampaignStatusChart;
