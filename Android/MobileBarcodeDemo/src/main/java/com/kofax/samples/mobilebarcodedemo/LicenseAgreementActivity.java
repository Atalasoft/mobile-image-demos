package com.kofax.samples.mobilebarcodedemo;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.webkit.WebView;

import com.kofax.samples.mobilebarcodedemo.R;

public class LicenseAgreementActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_license_agreement);
        Toolbar toolbar = (Toolbar) findViewById(R.id.lic_toolbar);
        setSupportActionBar(toolbar);

        // these 2 lines enable back button
//        getSupportActionBar().setHomeButtonEnabled(true);
//        getSupportActionBar().setDisplayHomeAsUpEnabled(true);


        WebView licAgreementTextView = (WebView) findViewById(R.id.lic_agreement);

        String str = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n" +
                "<HTML>\n" +
                "<HEAD>\n" +
                "<META HTTP-EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=us-ascii\">\n" +
                "<TITLE></TITLE>\n" +
                "<META NAME=\"GENERATOR\" CONTENT=\"OpenOffice 4.1.1  (FreeBSD/amd64)\">\n" +
                "<META NAME=\"CREATED\" CONTENT=\"20180125;11134000\">\n" +
                "<META NAME=\"CHANGED\" CONTENT=\"0;0\">\n" +
                "<STYLE TYPE=\"text/css\">\n" +
                "\t<!--\n" +
                "\t\t@page { margin: 0.5in }\n" +
                "\t\tP { margin-bottom: 0.08in }\n" +
                "\t\tA:link { so-language: zxx }\n" +
                "\t-->\n" +
                "\t</STYLE>\n" +
                "</HEAD>\n" +
                "<BODY LANG=\"en-US\" DIR=\"LTR\" STYLE=\"border: none; padding: 0in\">\n" +
                "<P STYLE=\"margin-top: 0.07in; margin-bottom: 0.07in\"><FONT SIZE=2>This\n" +
                "End-User License Agreement (&ldquo;Agreement&rdquo;) governs your use\n" +
                "of the Atalasoft Mobile Application software (&ldquo;Software&rdquo;)\n" +
                "provided by Atalasoft, Inc and its affiliates (&ldquo;Atalasoft&rdquo;).\n" +
                "Your use of the Software constitutes your acceptance of the terms of\n" +
                "this Agreement. Your use of the Software is also subject to the\n" +
                "signed agreement between Atalasoft and your employer or in the\n" +
                "absence of a signed agreement, Atalasoft&rsquo;s standard license\n" +
                "terms as made available at </FONT><A HREF=\"http://www.Kofax.com/\"><FONT COLOR=\"#0000ff\"><FONT SIZE=2><U>www.Kofax.com</U></FONT></FONT></A><FONT SIZE=2>.</FONT></P>\n" +
                "<P STYLE=\"margin-top: 0.07in; margin-bottom: 0.07in\"><FONT SIZE=2><B>1.\n" +
                "License.</B></FONT><FONT SIZE=2> Atalasoft grants to you a\n" +
                "nontransferable, nonexclusive, license to install and use one copy of\n" +
                "the Software, in object code form only, solely on your mobile device.\n" +
                "You agree to the following license restrictions: (a) to not\n" +
                "duplicate, copy or redistribute the Software except as necessary for\n" +
                "use on your mobile device; and (b) to not modify, translate, make\n" +
                "derivative works of, disassemble, reverse engineer or otherwise use\n" +
                "the Software in order to build competitive technologies or for\n" +
                "competitive benchmark purposes.</FONT></P>\n" +
                "<P STYLE=\"margin-top: 0.07in; margin-bottom: 0.07in\"><FONT SIZE=2><B>2.\n" +
                "Generally.</B></FONT><FONT SIZE=2> You agree that Atalasoft shall not\n" +
                "have any liability to you for your use of the Software, including not\n" +
                "limited to your access or creation of content using the Software. By\n" +
                "using the Software, you acknowledge and agree that Atalasoft is not\n" +
                "responsible for examining or evaluating the content, accuracy,\n" +
                "completeness, timeliness, validity, copyright compliance, legality,\n" +
                "decency, quality or any other aspect of the content accessed or\n" +
                "created by You You further agree not to use the Software to infringe\n" +
                "or violate the rights of any other party, and that Atalasoft is not\n" +
                "in any way responsible for any such use by you. </FONT>\n" +
                "</P>\n" +
                "<P STYLE=\"margin-top: 0.07in; margin-bottom: 0.07in\"><FONT SIZE=2>Atalasoft\n" +
                "reserves the right to change, terminate, or disable access to the\n" +
                "Software as is reasonably necessary to ensure compliance with this\n" +
                "Agreement. In no event will Atalasoft be liable for the change,\n" +
                "removal of, termination, or disabling of access to the Software. </FONT>\n" +
                "</P>\n" +
                "<P STYLE=\"margin-top: 0.07in; margin-bottom: 0.07in\"><FONT SIZE=2><B>3.\n" +
                "Limitation Of Liability.</B></FONT><FONT SIZE=2> To the extent not\n" +
                "prohibited by law, in no event shall Atalasoft be liable for personal\n" +
                "injury, or any incidental, special, indirect or consequential\n" +
                "damages, including, without limitation, damages for loss of profits,\n" +
                "loss of data, business interruption or any other commercial damages\n" +
                "or losses, arising out of or related to your use or inability to use\n" +
                "the Software or Services, however caused, regardless of the theory of\n" +
                "liability (contract, tort or otherwise) and even if Atalasoft has\n" +
                "been advised of the possibility of such damages. In no event shall\n" +
                "Atalasoft&rsquo;s total liability to you for all damages (other than\n" +
                "as may be required by applicable law in cases involving personal\n" +
                "injury) exceed the amount price paid for the Software, if any. The\n" +
                "foregoing limitations will apply even if the above stated remedy\n" +
                "fails of its essential purpose.</FONT></P>\n" +
                "<P STYLE=\"margin-top: 0.07in; margin-bottom: 0.07in\"><FONT SIZE=2>Some\n" +
                "jurisdictions do not allow the limitation of liability for personal\n" +
                "injury, or of incidental or consequential damages, so this limitation\n" +
                "may not apply to you.</FONT></P>\n" +
                "<P STYLE=\"margin-top: 0.07in; margin-bottom: 0.07in\"><FONT SIZE=2><B>4.\n" +
                "Indemnification By You.</B></FONT><FONT SIZE=2> You agree to\n" +
                "indemnify and hold Atalasoft, its subsidiaries, and affiliates, and\n" +
                "their respective officers, agents, partners and employees, harmless\n" +
                "from any loss, liability, claim or demand, including reasonable\n" +
                "attorney&rsquo;s fees, made by any third party due to or arising out\n" +
                "of your use of the Software in violation of this Agreement, and in\n" +
                "the event that any content accessed or created by you causes\n" +
                "Atalasoft to be liable to another.</FONT></P>\n" +
                "</BODY>\n" +
                "</HTML>";
        licAgreementTextView.loadData(str, "text/html; charset=utf-8", "UTF-8" );
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

}
