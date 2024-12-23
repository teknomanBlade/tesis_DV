using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class UFOGrayDeath : MonoBehaviour
{
    
    //public Gray Gray { get; set; }
    public LevelManager Level;
    [SerializeField]
    private Material dissolveMaterial;
    [SerializeField]
    private Material dissolveMaterialSpinner;
    private MeshRenderer _renderer;
    private MeshRenderer _rendererSpinner;
    private Transform _UFOSpinner;
    private float _tick;
    private float _lifeSpan;
    private float _maxSpeed;
    private float _maxForce;
    private float _valueToChange;
    private bool _isDissapearing;
    Vector3 _velocity;
    [SerializeField]
    private Animator _anim;
    // Start is called before the first frame update
    void Awake()
    {
        _maxSpeed = 10f;
        _maxForce = 8f;
        _UFOSpinner = transform.Find("UFOSpinner");
        _renderer = GetComponent<MeshRenderer>();
        _rendererSpinner = _UFOSpinner.GetComponent<MeshRenderer>();
        _anim = transform.GetComponentInChildren<Animator>();
        _isDissapearing = false;
        SwitchDissolveMaterial(dissolveMaterial, dissolveMaterialSpinner);
        _lifeSpan = 8f;
        
    }

    // Update is called once per frame
    void Update()
    {
        RotateUFOSpinner();
        OnStage();
       
    }
    private void OnStage()
    {
        _tick += Time.deltaTime;
        if (_tick >= _lifeSpan)
        {
            _tick = 0f;
            PlayAnimBeamDeployed(false);
            StartCoroutine(LerpScaleDissolve(0f, 1f));
            /*if(_isDissapearing)
                Level.UFOsPool.ReturnObject(this);*/
        }
    }
    public void PlayAnimBeamDeployed(bool active)
    {
        _anim.SetBool("IsBeamDeployed", active);
    }
    public void ActiveDissolve()
    {
        PlayAnimBeamDeployed(true);
        StartCoroutine(LerpScaleDissolve(1f, 1f));
    }
    public void SwitchDissolveMaterial(Material material, Material materialSpinner)
    {
        var materials = _renderer.sharedMaterials.ToList();
        materials.Clear();
        materials.Add(material);
        _renderer.sharedMaterials = materials.ToArray();
        var materialsSpinner = _rendererSpinner.sharedMaterials.ToList();
        materialsSpinner.Clear();
        materialsSpinner.Add(materialSpinner);
        _rendererSpinner.sharedMaterials = materialsSpinner.ToArray();
    }

    public void RotateUFOSpinner()
    {
        _UFOSpinner.Rotate(new Vector3(0f, 180f * Time.deltaTime, 0f));
    }

    public UFOGrayDeath InitializePosition(Vector3 spawnerPos)
    {
        transform.localPosition = spawnerPos;
        return this;
    }

    public UFOGrayDeath SetOwner(LevelManager level)
    {
        Level = level;
        return this;
    }
    IEnumerator LerpScaleDissolve(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            _renderer.material.SetFloat("_ScaleDissolve", _valueToChange);
            _rendererSpinner.material.SetFloat("_ScaleDissolveSpinner", _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
        _isDissapearing = _valueToChange == 0;
    }
}
