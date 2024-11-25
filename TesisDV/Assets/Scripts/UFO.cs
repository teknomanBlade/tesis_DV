using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class UFO : MonoBehaviour
{
    private GameObject _UFOSpinner;
    [SerializeField]
    private Animator _animBeam;
    [SerializeField]
    private Animator _animUFO;
    private Coroutine _currentCoroutine;
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
    [Range(0, 1)]
    public float sliderSoundVolume;
    private float _spawnTimer;
    [SerializeField] private GameObject UFOIndicatorPrefab;
    private GameObject UFOIndicator;
    public Enemy currentGray;
    [SerializeField] private List<Enemy> EnemiesToSpawn = new List<Enemy>();
    public float timeLimit;
    public float timer;
    public bool spawning = false;
    private float _UFOSpeed = 50f;
    [SerializeField] private int _graysSpawned;
    [SerializeField] private bool _inPosition;
    [SerializeField] private bool _canLeavePlanet;
    private void Awake()
    {
        _inPosition = false;
        _spawnTimer = 5f;
        _arriveRadius = 20f;
        _maxSpeed = 30f;
        _maxForce = 12f;
        _canLeavePlanet = false;
        _UFOSpinner = GameObject.Find("UFOSpinner");
        _animUFO = GetComponent<Animator>();
        _animUFO.enabled = true;
        rotationFinal = Quaternion.Euler(-90f, 0f, 0f);
        _audioSource = GetComponent<AudioSource>();
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _lm.OnRoundEnd += RoundEnd;
        _lm.AddUFO(this);
    }

    private void RoundEnd(int amountEnemies)
    {
        _canLeavePlanet = amountEnemies == 0;
    }

    void Start()
    {
        GameVars.Values.soundManager.PlaySound(_audioSource, "UFOBuzz", sliderSoundVolume, true, 1f);
    }

    public void PlayAnimBeam(bool active)
    {
        _animBeam.SetBool("IsBeamSpawnerDeployed", active);
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
    private void Update()
    {
        EnterPlanet();
        ExitPlanet();

        if (currentGray != null) SpawnGreyLerp();

        if (timer >= timeLimit)
        {
            if (currentGray != null)
            {
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

    public void BeginSpawn()
    {
        StopCoroutine(_currentCoroutine);
        spawning = true;
        PlayAnimBeam(true);
        _currentCoroutine = StartCoroutine("SpawnGrey");
    }

    IEnumerator SpawnGrey()
    {
        yield return new WaitForSeconds(_spawnTimer);
        yield return new WaitUntil(() => this.enabled);
        if (_graysSpawned < EnemiesToSpawn.Count())
        {
            if (!Physics.CheckBox(transform.position - checkCubePos, checkCubeExt, Quaternion.identity, 1 << LayerMask.NameToLayer("Enemy")))
            {
                //CAMBIO PARA MVC
                //La referencia cambia a GrayModel
                //currentGray = Instantiate(EnemiesToSpawn[_graysSpawned], transform.position - startPos, Quaternion.identity, parent.transform).GetComponent<Enemy>().SetExitUFO(transform.position);
                currentGray = EnemiesToSpawn[_graysSpawned].SetExitUFO(transform.position);
                currentGray.gameObject.SetActive(true);
                GameVars.Values.enemyCount++;
                AssignCountToEnemyByPairImpair(GameVars.Values.enemyCount, currentGray);
                //_lm.EnemySpawned();
                //SpawnGreyLerp();
                spawning = false;
                _graysSpawned++;
            }
            else StartCoroutine("SpawnGrey");
        }
    }
    public void AssignCountToEnemyByPairImpair(int count, Enemy enemy)
    {
        if (gameObject.name.Contains("a") && count % 2 == 0)
        {
            enemy.SetName(count.ToString());
        }
        else
        {
            enemy.SetName(count.ToString());
        }
    }
    public void ExitPlanet()
    {
        Vector3 dir = _spawnPos - transform.position;
        if (_canLeavePlanet)
        {
            StartCoroutine(PlayAnimRetractBeam());
            transform.position = Vector3.MoveTowards(transform.position, _spawnPos, _UFOSpeed * Time.deltaTime);
            if (dir.magnitude < 0.2f)
            {
                _animUFO.enabled = true;
                _animUFO.SetBool("IsWarping", true);
            }
        }

    }

    public void DestroyUFO()
    {
        GameVars.Values.LevelManager.RemoveUFO(this);
        GameVars.Values.IsUFOExitPlanetAnimFinished = true;
        Invoke(nameof(DestroyAndSetFalseAnimFinished),2f);
    }
    public void DestroyAndSetFalseAnimFinished() 
    {
        GameVars.Values.IsUFOExitPlanetAnimFinished = false;
        Destroy(this.gameObject);
    }

    IEnumerator PlayAnimRetractBeam()
    {
        PlayAnimBeam(false);
        yield return new WaitForSeconds(2f);
    }
    private void EnterPlanet()
    {
        Vector3 dir = _finalPos - transform.position;
        if (!_inPosition)
        {
            _currentCoroutine = StartCoroutine(PlayAnimation("IsArriving", "UFOSpawnerWarpArrive"));
            PlayAnimBeam(false);
            if (dir.magnitude < 0.2f)
            {
                BeginSpawn();
                _inPosition = true;
            }
            Move();
            Arrive();
        }
    }
    IEnumerator PlayAnimation(string param, string name)
    {
        _animUFO.SetBool(param, true);
        var clips = _animUFO.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        yield return new WaitForSeconds(time);
        _animUFO.SetBool(param, false);
        _animUFO.enabled = false;
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
    public UFO SetName(string name) 
    {
        gameObject.name += name;
        return this;
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

    public UFO SetGraysToSpawn(List<Enemy> enemies)
    {
        EnemiesToSpawn = enemies;
        return this;
    }

    public UFO SetRotation(Vector3 newRotation)
    {
        transform.rotation *= Quaternion.Euler(newRotation);
        return this;
    }
}
