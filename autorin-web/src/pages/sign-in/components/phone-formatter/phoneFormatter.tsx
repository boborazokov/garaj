import type { ChangeEvent } from "react";
import { Input, type InputProps } from "antd";
import { PHONE_NUMBER_COUNTRY_CODE } from "@/lib/constants";
import { cleanPhone, formatPhoneNumber } from "@/lib/helpers/phone.helpers";

export function PhoneInput({ value, onChange, ...props }: InputProps) {
  const safeValue = typeof value === "string" ? value : "";
  const formattedValue = formatPhoneNumber(safeValue);

  const handleChangeInput = (event: ChangeEvent<HTMLInputElement>) => {
    const rawValue = cleanPhone(event.target.value ?? "");
    const nextEvent = {
      ...event,
      target: {
        ...event.target,
        value: rawValue,
      },
      currentTarget: {
        ...event.currentTarget,
        value: rawValue,
      },
    } as ChangeEvent<HTMLInputElement>;

    onChange?.(nextEvent);
  };

  return (
    <Input
      {...props}
      type="tel"
      value={formattedValue}
      onChange={handleChangeInput}
      maxLength={17}
      prefix={
        <span style={{ color: "#475569", fontWeight: 600, marginRight: 4 }}>
          {PHONE_NUMBER_COUNTRY_CODE}
        </span>
      }
    />
  );
}
