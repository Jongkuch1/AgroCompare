import { DATA_NOTICE } from "../data/prices.js";

export default function DemoNotice() {
  return (
    <div className="notice" role="note">
      <strong>{DATA_NOTICE}</strong> Market names and locations are sample placeholders.
    </div>
  );
}
