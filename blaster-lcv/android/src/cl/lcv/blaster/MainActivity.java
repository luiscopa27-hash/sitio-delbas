package cl.lcv.blaster;

import android.app.Activity;
import android.content.Intent;
import android.content.res.AssetManager;
import android.net.Uri;
import android.os.Bundle;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.print.PrintManager;
import android.util.Base64;
import android.webkit.JavascriptInterface;
import android.webkit.MimeTypeMap;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import java.io.InputStream;
import java.io.OutputStream;

/**
 * Contenedor de blaster.lcv: muestra la app web incluida en el APK (funciona sin internet)
 * y le agrega lo que el navegador no puede hacer solo: abrir archivos, guardar exportaciones
 * con el diálogo «Guardar como» de Android e imprimir con el servicio de impresión.
 */
public class MainActivity extends Activity {
    /** Origen https propio para los archivos de la app: así el almacenamiento local funciona como en un sitio web. */
    private static final String HOST = "appassets.androidplatform.net";
    private static final String START_URL = "https://" + HOST + "/index.html";
    private static final int REQ_OPEN = 1;
    private static final int REQ_SAVE = 2;

    private WebView web;
    private ValueCallback<Uri[]> fileCallback;
    private byte[] pendingData;

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        web = new WebView(this);
        setContentView(web);

        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setAllowFileAccess(false);
        s.setSupportZoom(false);
        s.setBuiltInZoomControls(false);
        s.setUseWideViewPort(true);
        s.setLoadWithOverviewMode(true);
        s.setTextZoom(100);

        web.setWebViewClient(new WebViewClient() {
            @Override
            public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
                Uri u = request.getUrl();
                if (!HOST.equals(u.getHost())) return null;
                return asset(u.getPath());
            }

            @Override
            @SuppressWarnings("deprecation")
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                Uri u = Uri.parse(url);
                if (HOST.equals(u.getHost())) return false;
                // Enlaces externos: se abren en el navegador del equipo.
                try { startActivity(new Intent(Intent.ACTION_VIEW, u)); } catch (Exception e) { /* sin navegador */ }
                return true;
            }
        });

        web.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView view, ValueCallback<Uri[]> callback, FileChooserParams params) {
                if (fileCallback != null) fileCallback.onReceiveValue(null);
                fileCallback = callback;
                Intent i = new Intent(Intent.ACTION_GET_CONTENT);
                i.addCategory(Intent.CATEGORY_OPENABLE);
                String[] types = params.getAcceptTypes();
                String accept = types != null && types.length > 0 ? types[0] : "";
                i.setType(accept.contains("json") ? "*/*" : accept.contains("pdf") ? "application/pdf" : "*/*");
                try {
                    startActivityForResult(Intent.createChooser(i, "Elegir archivo"), REQ_OPEN);
                } catch (Exception e) {
                    fileCallback = null;
                    return false;
                }
                return true;
            }
        });

        web.addJavascriptInterface(new Bridge(), "AndroidBridge");
        if (state != null) web.restoreState(state);
        else web.loadUrl(START_URL);
    }

    /** Sirve un archivo de assets/www con su tipo MIME. */
    private WebResourceResponse asset(String path) {
        if (path == null || path.equals("/") || path.isEmpty()) path = "/index.html";
        try {
            AssetManager am = getAssets();
            InputStream in = am.open("www" + path);
            String ext = MimeTypeMap.getFileExtensionFromUrl(path);
            String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
            if (path.endsWith(".js")) mime = "application/javascript";
            else if (path.endsWith(".webmanifest")) mime = "application/manifest+json";
            else if (path.endsWith(".svg")) mime = "image/svg+xml";
            if (mime == null) mime = "application/octet-stream";
            String enc = mime.startsWith("text/") || mime.endsWith("javascript") || mime.endsWith("json") ? "UTF-8" : null;
            return new WebResourceResponse(mime, enc, in);
        } catch (Exception e) {
            return new WebResourceResponse("text/plain", "UTF-8", 404, "Not Found", null, null);
        }
    }

    /** Funciones nativas que llama la app web (window.AndroidBridge). */
    private class Bridge {
        @JavascriptInterface
        public void saveFile(final String name, final String mime, String base64) {
            pendingData = Base64.decode(base64, Base64.DEFAULT);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Intent i = new Intent(Intent.ACTION_CREATE_DOCUMENT);
                    i.addCategory(Intent.CATEGORY_OPENABLE);
                    i.setType(mime);
                    i.putExtra(Intent.EXTRA_TITLE, name);
                    try {
                        startActivityForResult(i, REQ_SAVE);
                    } catch (Exception e) {
                        pendingData = null;
                        Toast.makeText(MainActivity.this, "No se pudo abrir el diálogo para guardar.", Toast.LENGTH_LONG).show();
                    }
                }
            });
        }

        @JavascriptInterface
        public void print(final String jobName) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    PrintManager pm = (PrintManager) getSystemService(PRINT_SERVICE);
                    PrintDocumentAdapter adapter = web.createPrintDocumentAdapter(jobName);
                    pm.print(jobName, adapter, new PrintAttributes.Builder().build());
                }
            });
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQ_OPEN) {
            if (fileCallback != null) {
                Uri[] result = null;
                if (resultCode == RESULT_OK && data != null && data.getData() != null) result = new Uri[]{data.getData()};
                fileCallback.onReceiveValue(result);
                fileCallback = null;
            }
            return;
        }
        if (requestCode == REQ_SAVE) {
            if (resultCode == RESULT_OK && data != null && data.getData() != null && pendingData != null) {
                try {
                    OutputStream out = getContentResolver().openOutputStream(data.getData());
                    out.write(pendingData);
                    out.close();
                    Toast.makeText(this, "Archivo guardado.", Toast.LENGTH_SHORT).show();
                } catch (Exception e) {
                    Toast.makeText(this, "No se pudo guardar el archivo.", Toast.LENGTH_LONG).show();
                }
            }
            pendingData = null;
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onSaveInstanceState(Bundle out) {
        super.onSaveInstanceState(out);
        web.saveState(out);
    }

    @Override
    public void onBackPressed() {
        if (web.canGoBack()) web.goBack();
        else super.onBackPressed();
    }
}
