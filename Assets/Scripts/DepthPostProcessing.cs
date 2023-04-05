using DG.Tweening;
using UnityEngine;

public class DepthPostProcessing : MonoBehaviour
{
    private static readonly int WAVE_NORMALIZED_DISTANCE = Shader.PropertyToID("_WaveNormalizedDistance");
    
    [SerializeField] private Camera _camera = null;
    [SerializeField] private Material _inverseMaterial = null;
    [SerializeField] private float _waveTime = 1f;

    private Tween _waveTween = null;

    private void Start()
    {
        var waveDistance = 0f;

        _waveTween = DOTween.To(() => waveDistance, value =>
        {
            waveDistance = value;
            _inverseMaterial.SetFloat(WAVE_NORMALIZED_DISTANCE, waveDistance);
        }, 1, _waveTime);
        _waveTween.SetLoops(-1);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        _camera.depthTextureMode = DepthTextureMode.Depth;
        Graphics.Blit(src, dest, _inverseMaterial);
    }
}
