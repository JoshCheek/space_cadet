import spaceCadet.*;

class RunTests {
  static function main() {
    var hadFailure = false;
    // SpaceCadet
      // define
      var root = new Description();

      spaceCadet.RunningASuiteSpec.describe(root);
      spaceCadet.AssertionsSpec.describe(root);
      spaceCadet.BeforeBlocksSpec.describe(root);
      spaceCadet.ReporterSpec.describe(root);

      toplevel.StackSpec.describe(root);
      toplevel.PrinterSpec.describe(root);
      toplevel.StringOutputSpec.describe(root);
      toplevel.EscapeStringSpec.describe(root);
      toplevel.InspectSpec.describe(root);

      // run
      var printer  = new Printer(Sys.stdout(), Sys.stderr());
      var reporter = new Reporter.StreamReporter(printer);
      Run.run(root, reporter, {failFast:true, printer: printer});
      hadFailure = hadFailure || 0 != reporter.numFailed;
      hadFailure = hadFailure || 0 != reporter.numErrored;

    // Finished
      if(hadFailure) Sys.exit(1);
  }
}
