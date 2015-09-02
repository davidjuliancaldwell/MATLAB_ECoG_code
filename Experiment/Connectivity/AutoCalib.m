function calibRange = AutoCalib(gloveInput)

    calibRange(:,1) = min(gloveInput(2000:end,:),[],1);
    calibRange(:,2) = max(gloveInput(2000:end,:),[],1);

end