# frozen_string_literal: true

require "open3"

RSpec.describe "executable" do
  it "runs the game executable without an error and quits",
     unless: RSpec::Support::OS.windows? do
    out, err, status = Open3.capture3("minehunter -c 7", stdin_data: "\nq")

    expect(out.inspect).to match(/ ░░░░░░░ /)
    expect(err).to eq("")
    expect(status.exitstatus).to eq(0)
  end
end
