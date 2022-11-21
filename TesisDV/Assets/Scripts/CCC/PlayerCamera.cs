using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class PlayerCamera : MonoBehaviour
{
    public Player _player;
    public GameObject _camera;
    public GameObject Camera { get; set; }
    public Animator Animator { get; set; }
    private Quaternion targetAngle;
    private Quaternion targetAngleShake;
    private float smoothing = 20f;
    private Vector3 offset = new Vector3(0f, 0.75f, 0f);

    //Bobbing
    private Vector3 _initPos;
    private float _toggleSpeed = 0.3f;
    private float _amplitude = 0.005f;
    private float _frequency = 10.0f;
    private float _valueToChange;
    [SerializeField] private float _stunDuration;
    private float _passedTime;
    private bool _isStunned = false;
    [SerializeField] private float _stunXAmplitude;
    [SerializeField] private float _stunYAmplitude;
    [SerializeField] private float _stunXFrequency;
    [SerializeField] private float _stunYFrequency;
 
    private void Awake()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        _camera = GameObject.Find("MainCamera");
        targetAngleShake = Quaternion.Euler(0.005f, -0.005f, 0f);
        Camera = _camera;
        Animator = Camera.GetComponent<Animator>();
        SetInitPos(_camera.transform.localPosition);
        _passedTime = _stunDuration;
    }

    private void LateUpdate()
    {
        if(!_isStunned)
        {
            CheckMotion();
            ResetPosition();

            transform.position = Vector3.Lerp(transform.position, _player.transform.position + offset, smoothing * Time.deltaTime);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetAngle, smoothing * Time.deltaTime);
        }
        else
        {
            
            if(_passedTime > 0)
            {
                _passedTime -= Time.deltaTime;
                PlayMotion(StunnedMotion());
            }
            else
            {
                RecoverPlayer();
                SwitchStunnedState(false);
                _passedTime = _stunDuration;
            }
            
            /* Vector3 dir = Vector3.down - transform.position;
            Quaternion lookRotation = Quaternion.LookRotation(dir);
            Vector3 rotation = lookRotation.eulerAngles;

            transform.rotation = Quaternion.Lerp(transform.rotation, Quaternion.Euler(0f, rotation.y, 0f), _stunRotationSpeed * Time.deltaTime); */
        }
    }

    public Vector3 GetForward()
    {
        return _camera.transform.forward;
    }

    public void ChangeAngles(Vector3 angles)
    {
        targetAngle = Quaternion.Euler(angles.x, angles.y, angles.z);
    }

    private void CheckMotion()
    {
        var pSpeed = _player.GetVelocity();
        float speed = new Vector3(pSpeed.x, 0, pSpeed.z).magnitude;

        if (speed < _toggleSpeed) return;
        if (!_player.isGrounded) return;
        PlayMotion(FootStepMotion());
    }

    private Vector3 FootStepMotion()
    {
        Vector3 pos = Vector3.zero;
        pos.y += Mathf.Sin(Time.time * _frequency) * _amplitude;
        pos.x += Mathf.Cos(Time.time * _frequency / 2) * _amplitude * 2;
        return pos;
    }

    private Vector3 StunnedMotion()
    {
        Vector3 pos = Vector3.zero;
        pos.y += Mathf.Sin(Time.time * _stunYFrequency) * _stunYAmplitude;
        pos.x += Mathf.Cos(Time.time * _stunXFrequency / 2) * _stunXAmplitude * 2;
        return pos;
    }

    private void ResetPosition()
    {
        if (_camera.transform.localPosition == _initPos) return;
        _camera.transform.localPosition = Vector3.Lerp(_camera.transform.localPosition, _initPos, 1 * Time.deltaTime);
    }

    private void PlayMotion(Vector3 motion)
    {
        _camera.transform.localPosition += motion;
    }
    public void ShakeRacketSwing()
    {
        StartCoroutine(ShakeCameraRacket(0.04f, 0.08f));
    }
    IEnumerator ShakeCameraRacket(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            transform.localRotation = Quaternion.Slerp(transform.localRotation, targetAngleShake, _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
    }
    public void CameraShakeDamage(float duration, float magnitude)
    {
        StartCoroutine(ShakeDamage(duration, magnitude));
    }

    public IEnumerator ShakeDamage(float duration, float magnitude)
    {

        Vector3 originalPos = Camera.transform.localPosition;

        float elapsed = 0.0f;

        while (elapsed < duration)
        {
            float x = Random.Range(-0.15f, 0.15f) * magnitude;
            float z = Random.Range(-0.15f, 0.15f) * magnitude;

            Camera.transform.localPosition = new Vector3(originalPos.x + x, originalPos.y, originalPos.z + z);

            elapsed += Time.deltaTime;

            yield return null;
        }

    }

    public void SwitchStunnedState(bool value)
    {
        _isStunned = value;
    }

    public void RecoverPlayer()//Se activa con evento en animacion de NotStunned.
    {
        _player.Recover();
    }

    public void SetInitPos(Vector3 newPos)
    {
        _initPos = newPos;
    }
}
