using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class UFO : MonoBehaviour
{
    private GameObject _UFOSpinner;
    [SerializeField]
    private Material nonDissolveMaterial;
    [SerializeField]
    private Material nonDissolveMaterialSpinner;
    [SerializeField]
    private Material dissolveMaterial;
    [SerializeField]
    private Material dissolveMaterialSpinner;
    [SerializeField]
    private Animator _anim;
    private Coroutine _currentCoroutine;
    private MeshRenderer _renderer;
    private MeshRenderer _rendererSpinner;
    private float _arriveRadius;
    private float _maxSpeed;
    private float _maxForce;
    public Vector3 _velocity;
    Quaternion rotationFinal;
    private LevelManager _lm;
    private AudioSource _audioSource;
    private float _valueToChange;
    private float _valueToChangeRot;
    public Vector3 checkCubePos = new Vector3(0f, 4f, 0f);
    public Vector3 checkCubeExt = new Vector3(4f, 4f, 4f);
    public Vector3 startPos;
    private Vector3 _spawnPos;
    private Vector3 _finalPos;
    public Vector3 endPos;
    [Range(0,1)]
    public float sliderSoundVolume;
    private float _spawnTimer;
    public GameObject grayPrefab;
    public Gray currentGray;
    public float timeLimit;
    public float timer;
    public bool spawning = false;
    private float _UFOSpeed = 50f;
    [SerializeField]
    private int _totalGrays;
    [SerializeField]
    private bool _inPosition;
    private bool _canLeavePlanet;


    private void Awake()
    {
        _inPosition =  false;
        _spawnTimer = 5f;
        _arriveRadius = 20f;
        _maxSpeed = 30f;
        _maxForce = 12f;
        _canLeavePlanet = false;
        _UFOSpinner = GameObject.Find("UFOSpinner");
        rotationFinal = Quaternion.Euler(-90f,0f,0f);
        _anim = transform.GetComponentInChildren<Animator>();
        _renderer = GetComponent<MeshRenderer>();
        _rendererSpinner = _UFOSpinner.GetComponent<MeshRenderer>();
        _audioSource = GetComponent<AudioSource>();
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        GameVars.Values.soundManager.PlaySound(_audioSource, "UFOBuzz", sliderSoundVolume, true, 1f);
    }

    private void RotateUFOSpinner()
    {
        _UFOSpinner.transform.Rotate(new Vector3(0f, 0f, 180f * Time.deltaTime));
    }
    public void PlayAnimBeam(bool active)
    {
        _anim.SetBool("IsBeamSpawnerDeployed", active);
    }
    public void Move()
    {
        if (_velocity != Vector3.zero)
        {
            _currentCoroutine = StartCoroutine(LerpRotation(1f, 1f));
            transform.position += _velocity * Time.deltaTime;
            transform.forward = _velocity;
        }
    }

    void Arrive()
    {
        Vector3 desired = (_finalPos - transform.position).normalized;
        float dist = Vector3.Distance(transform.position, _finalPos);
        float speed = _maxSpeed;
        if (dist <= _arriveRadius)
        {
            speed = _maxSpeed * (dist / _arriveRadius);
        }
        desired *= speed;

        Vector3 steering = Vector3.ClampMagnitude(desired - _velocity, _maxForce);

        ApplyForce(steering);
    }

    void ApplyForce(Vector3 force)
    {
        _velocity += force;
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

    private void Update()
    {
        RotateUFOSpinner();
        EnterPlanet();
        ExitPlanet();

        if (currentGray != null) SpawnGreyLerp();

        if (timer >= timeLimit)
        {
            if(currentGray != null)
            {
                currentGray.AwakeGray();
                BeginSpawn();
            }

            currentGray = null;
            timer = 0;
        }
    }
    IEnumerator LerpRotation(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChangeRot;

        while (time < duration)
        {
            _valueToChangeRot = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            transform.rotation = Quaternion.Lerp(transform.rotation, rotationFinal, _valueToChangeRot);
            yield return null;
        }

        _valueToChangeRot = endValue;
    }

    IEnumerator LerpScaleDissolve(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            dissolveMaterial.SetFloat("_ScaleDissolve", _valueToChange);
            dissolveMaterialSpinner.SetFloat("_ScaleDissolveSpinner", _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
    }
    public void BeginSpawn()
    {
        //if(_currentCoroutine != StartCoroutine("SpawnGrey"))
        //{
        //    StopCoroutine(_currentCoroutine);
        //}
        StopCoroutine(_currentCoroutine);
        spawning = true;
        PlayAnimBeam(true);
        _currentCoroutine = StartCoroutine("SpawnGrey");
    }

    IEnumerator SpawnGrey()
    {
        yield return new WaitForSeconds(_spawnTimer);
        if(_totalGrays > 0)
        {
            if (!Physics.CheckBox(transform.position - checkCubePos, checkCubeExt, Quaternion.identity, 1 << LayerMask.NameToLayer("Enemy")))
            {
                currentGray = Instantiate(grayPrefab, transform.position - startPos, Quaternion.identity).GetComponent<Gray>().SetExitUFO(transform.position);
                //_lm.EnemySpawned();
                //SpawnGreyLerp();
                spawning = false;
                _totalGrays--;
            }
            else StartCoroutine("SpawnGrey");
        }
        else
        {
            if(GameVars.Values.LevelManager.enemiesInScene.Count == 0)
            {
                _canLeavePlanet = true;
            }
            else StartCoroutine("SpawnGrey");
        }
    }

    private void ExitPlanet()
    {
        if (_canLeavePlanet)
        {
            StartCoroutine(PlayAnimRetractBeam());
            SwitchDissolveMaterial(dissolveMaterial, dissolveMaterialSpinner);
            transform.position = Vector3.MoveTowards(transform.position, _spawnPos, _UFOSpeed * Time.deltaTime);
            if(transform.position == _spawnPos)
            {
                StartCoroutine(LerpScaleDissolve(0f, 1f));
                Destroy(this.gameObject);
            }
        }
        
    }
    IEnumerator PlayAnimRetractBeam()
    {
        PlayAnimBeam(false);
        yield return new WaitForSeconds(1f);
        
    }
    private void EnterPlanet()
    {
        Vector3 dir = _finalPos - transform.position;
        if (!_inPosition)
        {
            PlayAnimBeam(false);
            SwitchDissolveMaterial(dissolveMaterial, dissolveMaterialSpinner);
            StartCoroutine(LerpScaleDissolve(1f, 1f));
            //if (transform.position == _finalPos)
            if(dir.magnitude < 0.2f)
            {
                //PlayAnimBeam(true);
                StopCoroutine(_currentCoroutine);
                SwitchDissolveMaterial(nonDissolveMaterial, nonDissolveMaterialSpinner);
                _currentCoroutine = StartCoroutine(LerpScaleDissolve(0f, 1f));
                BeginSpawn();
                _inPosition = true;
            }
            Move();
            Arrive();
            //transform.position = Vector3.MoveTowards(transform.position, _finalPos, _UFOSpeed * Time.deltaTime);
        }
    }

    public void SpawnGreyLerp()
    {
        currentGray.SetPos(Vector3.Lerp(transform.position - startPos, transform.position - endPos, timer / timeLimit));

        timer += Time.deltaTime;
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, _arriveRadius);
        Gizmos.DrawWireCube(transform.position - checkCubePos, checkCubeExt);
        Gizmos.DrawWireCube(transform.position - startPos, new Vector3(0.5f, 0.5f, 0.5f));
        Gizmos.DrawWireCube(transform.position - endPos, new Vector3(0.5f, 0.5f, 0.5f));
    }

    public UFO SetSpawnPos(Vector3 newPos)
    {
        transform.position = newPos;
        _spawnPos = newPos;
        return this;
    }

    public UFO SetFinalPos(Vector3 newPos)
    {
        _finalPos = newPos;
        return this;
    }

    public UFO SetTotalGrays(int totalGrays)
    {
        _totalGrays = totalGrays;
        return this;
    }

    public UFO SetRotation(Vector3 newRotation)
    {
        transform.rotation *= Quaternion.Euler(newRotation);
        return this;
    }
}
