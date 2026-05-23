{ inputs, ... }:
{
  _module.args.devpackThirdPartySkills = [
    {
      id = "academic-research";
      variants = {
        claude = [
          {
            name = "academic-paper";
            path = "${inputs.academic-research-skills}/academic-paper";
          }
          {
            name = "academic-paper-reviewer";
            path = "${inputs.academic-research-skills}/academic-paper-reviewer";
          }
          {
            name = "academic-pipeline";
            path = "${inputs.academic-research-skills}/academic-pipeline";
          }
          {
            name = "deep-research";
            path = "${inputs.academic-research-skills}/deep-research";
          }
        ];

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
