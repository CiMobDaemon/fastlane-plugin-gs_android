describe Fastlane::Actions::GsAndroidAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The gs_android plugin is working!")

      Fastlane::Actions::GsAndroidAction.run(nil)
    end
  end
end
