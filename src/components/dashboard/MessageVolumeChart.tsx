import React from "react";
import { Card } from "@/components/ui/card";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

interface MessageVolumeData {
  date: string;
  volume: number;
}

interface MessageVolumeChartProps {
  data?: MessageVolumeData[];
}

const defaultData: MessageVolumeData[] = [
  { date: "2024-01-01", volume: 4000 },
  { date: "2024-01-02", volume: 3000 },
  { date: "2024-01-03", volume: 5000 },
  { date: "2024-01-04", volume: 2780 },
  { date: "2024-01-05", volume: 1890 },
  { date: "2024-01-06", volume: 2390 },
  { date: "2024-01-07", volume: 3490 },
];

const MessageVolumeChart = ({
  data = defaultData,
}: MessageVolumeChartProps) => {
  return (
    <Card className="w-full h-[400px] p-4 bg-slate-800">
      <h3 className="text-lg font-semibold mb-4 text-white">
        Message Volume Over Time
      </h3>
      <div className="w-full h-[320px]">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart
            data={data}
            margin={{
              top: 5,
              right: 30,
              left: 20,
              bottom: 5,
            }}
          >
            <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
            <XAxis dataKey="date" stroke="#94a3b8" tick={{ fill: "#94a3b8" }} />
            <YAxis stroke="#94a3b8" tick={{ fill: "#94a3b8" }} />
            <Tooltip
              contentStyle={{
                backgroundColor: "#1e293b",
                border: "none",
                borderRadius: "8px",
                color: "#fff",
              }}
              labelStyle={{ color: "#94a3b8" }}
            />
            <Line
              type="monotone"
              dataKey="volume"
              stroke="#3b82f6"
              strokeWidth={2}
              dot={{ fill: "#3b82f6", strokeWidth: 2 }}
              activeDot={{ r: 8 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
};

export default MessageVolumeChart;
