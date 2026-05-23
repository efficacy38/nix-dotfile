{ inputs, ... }:
{
  _module.args.devpackThirdPartySkills = [
    {
      id = "academic-research";
      variants = {
        codex = [
          {
            name = "academic-research-suite";
            path = "${inputs.academic-research-skills-codex}/skills/academic-research-suite";
          }
        ];
      };
    }
  ];
}
