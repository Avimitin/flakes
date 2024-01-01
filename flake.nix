{
  description = "Flakes";

  outputs = { self }:
    {
      templates = import ./templates;
    };
}
